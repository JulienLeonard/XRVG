#!/usr/bin/env ruby

inp = File.open('SHIFTJIS.TXT', 'r')

comment = /^#.*/
record  = /^0x([0-9a-zA-Z]+)\s0x([0-9a-zA-Z]+)*/

list = Array.new

inp.each_line {|line|
  if line =~ record then
    list.push($2)
  end
}

inp.close

list.sort!

outp = File.open('Shift_JIS.tbl', 'w')

list.each {|record|
  outp.print record, "\n"
}

outp.close
