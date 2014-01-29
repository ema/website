--- 
layout: post
title: "Antifeatures and Antibugs"
author_name: Emanuele Rocca
author_uri: http://www.linux.it/~ema
date: 2014-01-29 15:02:00
---
Software Engineering distinguishes between *software features* and *software
bugs*.

It is usually understood that features are positive, expected characteristics
of a computer program. Features make users happy by allowing them to do
something useful, interesting, or fun. Something *good*, anyways. Bugs are
instead undesirable and annoying. You're sitting there at your computer writing
a long email and the software crashes right before your email is sent. *Bad
stuff*.

Features are generally implemented by programmers on purpose, whereas bugs are
purely unintentional. They are *mistakes*. You don't make a mistake *on
purpose*.

We might at this point be inclined to think that: i) what is good for users is
done on purpose by software manufacturers; ii) what is bad for users was not
meant to be. It happened by mistake.

Here is a handy table to visualize this idea:

+----------+------------+------------+
|          | On purpose | By mistake |
+==========+============+============+
| **Good** | Feature    |            |
+----------+------------+------------+
| **Bad**  |            | Bug        |
+----------+------------+------------+

It seems to make a lot of sense. But you might have noticed that two cells of
the table are empty. Right!

In a great talk titled `When Free Software isn't better`_, Benjamin Mako Hill
mentions the concept of **antifeatures**, and how they relate to `Free
Software`_.  

Antifeatures are features that make the software do something users will hate.
Something they will hate *so much* they would pay to have those features
removed, if that's an option. Microsoft Windows 7 is used in the talk to
provide some examples of software antifeatures: the Starter Edition `does not
allow users to change their background image`_. Also, it limits the amount of
usable memory on the computer to 2GBs, regardless of how much memory the system
actually has.  Two antifeatures engineered to afflict users to the point that
they will purchase a more expensive version of the software, if they have the
means to do that.

I have another nice example. The Spotify music streaming service plays
advertisements between songs every now and then. To make sure users are annoyed
as much as possible, Spotify automatically pauses an advertisement if it
detects that the volume is being lowered. A poor Spotify user even `tried to
report the bug on The Spotify Community forum`_, only to find out that what she
naively considered as a software error was "intentional behavior". A
spectacular antifeature indeed.

Whenever a piece of technology does something you most definitely do not want
it to do, such as `allowing the NSA to take complete control of your Apple
iPhone`_, including turning on its microphone and camera against your will,
that's an antifeature.

+----------+-------------+------------+
|          | On purpose  | By mistake |
+==========+=============+============+
| **Good** | Feature     |            |
+----------+-------------+------------+
| **Bad**  | Antifeature | Bug        |
+----------+-------------+------------+

Both bugs and antifeatures are bad for users. The difference between them is
that antifeatures are *engineered*. Time and money are spent to make sure the
goal is reached. A testing methodology is followed. "Are we really sure
customers cannot change their wallpaper even if they try very very hard?" 

Engineering processes, of course, can fail. If the poor devils at Microsoft who
implemented those harassments would have made a mistake that allows users to
somehow change their wallpaper on Windows Starter... Well, I would call that a
glorious **antibug**.

+----------+-------------+------------+
|          | On purpose  | By mistake |
+==========+=============+============+
| **Good** | Feature     | Antibug    |
+----------+-------------+------------+
| **Bad**  | Antifeature | Bug        |
+----------+-------------+------------+

There is no place for antifeatures in Free and Open Source Software. Free
Software gives users *control* over what their software does. Imagine Mozilla
adding a feature to Firefox that sets your speakers volume to 11 and starts
playing a random song from the black metal artist `Burzum`_ every time you add
a bookmark, unless you pay for *Mozilla Firefox Premium Edition*. The source
code for Firefox is available under a free license. People who are not into
Burzum's music would immediately remove this neat antifeature.

I have spent many years of my life advocating Free and Open Source Software,
perhaps using the wrong arguments. `Mako's talk`_ made me think about all this
(thanks mate!). All these years I've been preaching about the technical
superiority of Free Software, despite evidence of thousands of bugs and
usability issues in the very programs I am using, and contributing to develop.

Free Software is not better than Proprietary Software per se. Sometimes it is,
sometimes it's not. But it gives you control, and freedom. When it annoys you,
when it doesn't do what you expect and want, you can be sure it's not on
purpose. And we can fix it together.

.. _When Free Software isn't better: http://mako.cc/copyrighteous/when-free-software-isnt-better-talk
.. _Mako's talk: http://mako.cc/copyrighteous/when-free-software-isnt-better-talk
.. _tried to report the bug on The Spotify Community forum: http://community.spotify.com/t5/Newcomers-and-Contribution/Pausing-when-lowering-volume/td-p/251718
.. _does not allow users to change their background image: http://superuser.com/questions/69601/how-do-i-change-the-wallpaper-of-windows-7-starter-edition
.. _Burzum: https://en.wikipedia.org/wiki/Burzum
.. _Free Software: https://en.wikipedia.org/wiki/Free_software
.. _allowing the NSA to take complete control of your Apple iPhone: http://www.pcworld.com/article/2083460/report-nsa-developed-software-for-backdoor-access-to-iphones.html
