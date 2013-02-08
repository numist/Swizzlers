Swizzlers
=========

The Swizzlers module provides robust, general-purpose swizzling utilities.

If you think this is a good idea, you should stop and make sure that your needs are not a symptom of more severe architectural problems.

Installation
------------

Include this repository's `xcodeproj` in your project, and import `Swizzlers/Swizzlers.h`.

Modules
-------

### Isa Swizzling ###

Robust isa swizzling is provided using the `nn_object_swizzleIsa` function. The following conditions must be met:

* A protocol with the same name as the swizzling class exists and is implemented by the swizzling class.
* The object is an instance of the swizzling class's superclass, or a subclass of the swizzling class's superclass.
* The swizzling class does not add any ivars or non-dynamic properties.

An object has been swizzled by a class if it conforms to that class's complementing protocol, allowing you to cast the object (after checking!) to a type that explicitly implements the protocol.

License/Credits
===============

If not for [Rob Rix](https://github.com/robrix/), this library would not exist. Which probably would have been a good thing.

This library is released under the terms of the MIT License. Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
