#!/usr/bin/env python3
#
# Copyright (c) 2020 Erik Bosman <erik@minemu.org>
#
# Permission  is  hereby  granted,  free  of  charge,  to  any  person
# obtaining  a copy  of  this  software  and  associated documentation
# files (the "Software"),  to deal in the Software without restriction,
# including  without  limitation  the  rights  to  use,  copy,  modify,
# merge, publish, distribute, sublicense, and/or sell copies of the
# Software,  and to permit persons to whom the Software is furnished to
# do so, subject to the following conditions:
#
# The  above  copyright  notice  and this  permission  notice  shall be
# included  in  all  copies  or  substantial portions  of the Software.
#
# THE SOFTWARE  IS  PROVIDED  "AS IS", WITHOUT WARRANTY  OF ANY KIND,
# EXPRESS OR IMPLIED,  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY,  FITNESS  FOR  A  PARTICULAR  PURPOSE  AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM,  DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT,  TORT OR OTHERWISE,  ARISING FROM, OUT OF OR IN
# CONNECTION  WITH THE SOFTWARE  OR THE USE  OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# (http://opensource.org/licenses/mit-license.html)
#

import sys

import intelhex, pdk

PIN = 0

def wave_func(pin):

    old = -1
    count = 0

    def func(new):
        nonlocal old, count
        new = new>>pin &1
        if old ^ new:
            if count > 0:
                 print("{} {}".format(old, count) )
            old, count = new, 0
        count += 1

    return func


if __name__ == '__main__':

    if len(sys.argv) != 2:
        print ("Usage: {} hexfile".format(sys.argv[0]), file=sys.stderr)
        sys.exit(1)

    func = wave_func(PIN)

    with open(sys.argv[1]) as f:
        program = pdk.parse_program(f.read(), arch='pdk14')

    ctx = pdk.new_ctx()

    while True:
        pa   = pdk.read_io_raw(ctx, 0x10)
        func(pa)
        pdk.step(program, ctx)

