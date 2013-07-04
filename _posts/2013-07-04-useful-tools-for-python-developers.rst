--- 
layout: post
title: "Useful tools for Python developers"
tags: [python, programming, tools, testing]
author_name: Emanuele Rocca
author_uri: http://twitter.com/emarocca
date: 2013-07-04 16:56:00
---
Python is a great language with an impressive number of tools designed to make
developers' life easier. Sometimes, however, the problem is getting to know
that these tools exist in the first place. By contributing to projects like
OpenStack's `Nova client`_ and Falcon_, I have recently come across some useful
tools that can seriously improve the quality of your code.

The first one is called `pyflakes`_,  a `passive checker` of Python programs
developed by Phil Frost. What it does is parsing your source files and checking
for possible errors such as undefined names and unused imports. Let's consider
the following example:

.. code-block:: python

    import urllib

    print "pyflakes example"
    urlib.urlopen('http://www.linux.it')

The code above contains a typo, we have misspelled *urllib*. Here is what
**pyflakes** thinks about our program::

    $ pyflakes example.py 
    example.py:1: 'urllib' imported but unused
    example.py:4: undefined name 'urlib'

On line 4 we try to use *urlib* which is not defined. Also, we import
*urllib* on line 1 and we do nothing with it. Our typo has been spotted!
Notice that, even though our program contains a print statement, 'pyflakes
example' has not been printed. That is because pyflakes *parses* the source
files it checks, without *importing* them, making it safe to use on modules
with side effects.

pyflakes can be installed with pip or apt-get.

The second tool I want to talk about is Ned Batchelder's `coverage.py`_.

No doubt you write unit tests for your programs. Right? Good. coverage.py is
out there to help you checking how much of your program is `actually covered`_.

Let's use as an example `codicefiscale`_, a Python project of mine.

First we install **coverage**::

    pip install coverage

Then we run our unit tests::

    $ coverage run --source=codicefiscale tests.py 
    .......
    ----------------------------------------------------------------------
    Ran 7 tests in 0.003s

We pass the module we want to test with **--source=codicefiscale** so that
coverage will only report information about that specific module.

Now that our tests have been performed successfully it is time to check how
much of our code is covered by unit tests::

    $ coverage report -m                                                                                                                        
    Name            Stmts   Miss  Cover   Missing
    ---------------------------------------------
    codicefiscale      73      4    95%   61, 67, 95, 100

Not bad, 95% of our module is covered! Still, coverage let us know that 4 lines
have not been touched by the unit tests. With this information, we can go write
some meaningful test cases that will also cover the missing lines.

.. _Nova client: https://github.com/openstack/python-novaclient
.. _Falcon: https://github.com/racker/falcon
.. _pyflakes: https://pypi.python.org/pypi/pyflakes
.. _coverage.py: http://nedbatchelder.com/code/coverage
.. _actually covered: https://en.wikipedia.org/wiki/Code_coverage
.. _codicefiscale: https://crate.io/packages/codicefiscale
