include(`header.html.m4')

<h2>A brief introduction to SystemTap</h2>

<p>
SystemTap allows to instrument Linux systems at runtime. By using it, you can
gather insights about running programs, including the Linux kernel itself,
without invoking them in specific ways, modifying them, or indeed even have
access to their source code.
</p>

<p>
On Debian systems and derivatives, including Ubuntu, you can get started with
SystemTap by installing the <b>systemtap</b> package as well as the Linux
kernel headers:
</p>

<pre>
apt install systemtap linux-headers-$(uname -r)
</pre>

<p>
To verify that SystemTap is working correctly you can try this hello world
oneliner:
</p>

<pre>
$ sudo stap -v -e 'probe oneshot { println("hello world") }'
Pass 1: parsed user script and 476 library scripts using 101404virt/87992res/6960shr/81096data kb, in 150usr/30sys/218real ms.
Pass 2: analyzed script: 1 probe, 1 function, 0 embeds, 0 globals using 102988virt/89752res/7152shr/82680data kb, in 10usr/0sys/7real ms.
Pass 3: using cached /root/.systemtap/cache/28/stap_2871d732a80a0612c98a3e7e9d7dc4a2_973.c
Pass 4: using cached /root/.systemtap/cache/28/stap_2871d732a80a0612c98a3e7e9d7dc4a2_973.ko
Pass 5: starting run.
hello world
Pass 5: run completed in 10usr/20sys/494real ms.
</pre>

<p>
Give it another go without <b>-v</b> for more terse and less exciting output.
</p>

<p>
Now that SystemTap is installed and working on your machine, let's use it to
see what <b>ls</b> is doing under the hood. In order for SystemTap to inspect
the behavior of a given program it needs to have access to its debugging
symbols, which in the case of <b>ls</b> on Debian are provided by the
<b>coreutils-dbgsym</b> package. Once that is installed, you can ask SystemTap
to list all available <i>probe points</i>, which to simplify a little we can
for now say are equivalent to the program C functions. Let's list as an example
all functions that might have something to do with usernames:
</p>

<pre>
$ sudo stap -L 'process("/bin/ls").function("*")' | grep user
process("/bin/ls").function("format_user@src/ls.c:3955") $u:uid_t $width:int $stat_ok:_Bool
process("/bin/ls").function("format_user_or_group@src/ls.c:3927") $name:char const* $id:long unsigned int $width:int
process("/bin/ls").function("format_user_or_group_width@src/ls.c:3973") $id:long unsigned int
process("/bin/ls").function("format_user_width@src/ls.c:3991") $u:uid_t
process("/bin/ls").function("getgroup@lib/idcache.c:151") $gid:gid_t $match:struct userid*
process("/bin/ls").function("getuidbyname@lib/idcache.c:105") $user:char const*
process("/bin/ls").function("getuser@lib/idcache.c:69") $uid:uid_t $match:struct userid*
</pre>

<p>
The <b>format_user</b> function seems interesting. We can see that it takes
three arguments: <b>u</b>, <b>width</b>, and <b>stat_ok</b>. Let's print all
invocations of the functions, as well as the value of <b>u</b>:
</p>

<pre>
$ sudo stap -e 'probe process("/bin/ls").function("format_user") { printf("format_user(uid=%d)\n", $u) }'
</pre>

<p>
If SystemTap complains about a <i>Build-id mismatch</i>, try again passing
<b>-DSTP_NO_BUILDID_CHECK</b> on the command line. In case you're curious, you
can read <b>man error::buildid</b> to find out more about this.
</p>

<p>
Now try running <b>ls -l /etc/passwd</b>, and you should see the following
output from SystemTap:
</p>

<pre>
format_user(uid=0)
</pre>

<p>
By omitting <b>-l</b>, we can see that SystemTap produces no output, indicating
that <b>ls</b> does not call the <b>format_user</b> function in that case.
</p>

<p>
SystemTap is a fully-fledged programming language with variables, loops,
conditionals and so forth. One-liners on the shell are fine for exploration and
simple examples like the ones above, but for longer scripts you might want to
save your work on a file. Let's do that by creating <b>ls_non_root.stp</b>, a
file that slightly changes our previous example by only printing
<b>format_user</b> calls for files owned by non-root users:
</p>

<pre>
// SystemTap example: ls_non_root.stp
probe process("/bin/ls").function("format_user") {
    if ($u != 0) {
        printf("format_user(uid=%d)\n", $u)
    }
}
</pre>

<p>
Run the script with <b>stap -v ls_non_root.stp</b> and you should now see some
output only when running <b>ls -l</b> on files owned by users other than root.
</p>

<p>
How about the Linux kernel? Just as we did before for <b>coreutils</b>, we need
to install the debugging symbols for the kernel currently running. What is
different though, is that the kernel debug symbols are huge. For example, in
the case of the 4.19 kernel the debug symbols are about 5G. Make sure you've
got plenty of disk space available and the patience needed while waiting for
<b>apt install linux-image-$(uname -r)-dbg</b> to do its thing.
</p>

<p>
Now let's look for available Linux kernel probe points matching the
<b>*icmp*reply*</b> pattern:
</p> 

<pre>
$ sudo stap -L 'kernel.function("*icmp*reply*")' 
kernel.function("icmp_push_reply@./net/ipv4/icmp.c:367") $icmp_param:struct icmp_bxm* $fl4:struct flowi4* $ipc:struct ipcm_cookie* $rt:struct rtable**
kernel.function("icmp_reply@./net/ipv4/icmp.c:402") $icmp_param:struct icmp_bxm* $skb:struct sk_buff* $ipc:struct ipcm_cookie $fl4:struct flowi4
kernel.function("icmpv6_echo_reply@./net/ipv6/icmp.c:670") $skb:struct sk_buff* $tmp_hdr:struct icmp6hdr $fl6:struct flowi6 $msg:struct icmpv6_msg $ipc6:struct ipcm6_cookie
</pre>

<p>
Interesting! Let's see <b>ping localhost</b> in one terminal and see if, as
you'd expect, the <b>icmp_reply</b> function gets called:
</p>

<pre>
stap -ve 'probe kernel.function("icmp_reply") { println("reply") }'
</pre>

<p>
Silence. Ha! localhost is <b>::1</b> here. The function we're looking for is
<b>icmpv6_echo_reply</b>. We can extend the script as follows, and see when the
kernel is sending both v4 and v6 echo replies.
</p>

<pre>
// v4/v6 echo reply
probe kernel.function("icmp_reply") {
    println("Sending v4 echo reply")
}

probe kernel.function("icmpv6_echo_reply") {
    println("Sending v6 echo reply")
}
</pre>

<p>
We've just scratched the surface of what SystemTap can do. Go ahead and <a
href="https://sourceware.org/systemtap/documentation.html">read the
documentation</a>, play with it, and have fun.
</p>

include(`footer.html.m4')
