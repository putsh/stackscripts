# Stackscripts

My two cents worth of stackscripts

## linode/nginx-rvm-unicorn-mysql [[link]](https://www.linode.com/stackscripts/view/?StackScriptID=7163)

This Linode stackscript installs:

- Nginx - [https://github.com/nginx/nginx](https://github.com/nginx/nginx)
- RVM - [https://rvm.io](https://rvm.io)
- Ruby (at default "2.0.0") - [http://www.ruby-lang.org/en](http://www.ruby-lang.org/en)
- Unicorn - [https://github.com/defunkt/unicorn](https://github.com/defunkt/unicorn)
- MySQL - [http://www.mysql.com](http://www.mysql.com)
- `/etc/init.d/unicorn` - [linode/nginx-rvm-unicorn-mysql/unicorn](https://github.com/archan937/stackscripts/blob/master/linode/nginx-rvm-unicorn-mysql/unicorn)
- `mash` - [utils/mash](https://github.com/archan937/stackscripts/blob/master/utils/mash) for basic command line templating

Optionally, you can create a user and generate a simple "Hello world!" Rack application.

## License

Copyright (c) 2013 Paul Engel, released under the MIT license

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.