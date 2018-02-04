#!/usr/bin/env ruby
require 'gli'
require 'hacer'

include GLI::App

program_desc 'A simple todo list'

flag [:t,:tasklist], :default_value => File.join(ENV['HOME'],'.todolist')

pre do |global_options,command,options,args|
  $todo_list = Hacer::Todolist.new(global_options[:tasklist])
end

command :add do |c|
  c.action do |global_options,options,args|
    $todo_list.create(args)
  end
end

command :list do |c|
  c.action do
    $todo_list.list.each do |todo|
      printf("%5d - %s\n",todo.todo_id,todo.text)
    end
  end
end

command :done do |c|
  c.action do |global_options,options,args|
    id = args.shift.to_i
    $todo_list.list.each do |todo|
      $todo_list.complete(todo) if todo.todo_id == id
    end
  end
end

exit run(ARGV)