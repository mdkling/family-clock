#!/usr/bin/ruby
# Simple "Weasly Clock" implementation using
# ifftt.com 'iOS Location'>>'Maker Channel' REST requests to a Sinatra backend
# A secondary thread handles the external control logic in parallel
# including an (optional) hard-coded schedule

require 'sinatra'
require 'date'

#Initialize Global ($) variables
$all_user_states = {
                  "mike" => "Terra Incognito",
                  "samantha" => "Terra Incognito"
                  }

#frontend methods
def update_frontend(user,status)
  $all_user_states[user] = status
  puts $all_user_states
end


############################
### Control Logic Thread ###
############################

control_logic_thread = Thread.new do
  #sleep the main thread while Sinatra comes online
  puts "Wating for Sinatra"
  sleep(0.5)
  puts "Starting control logic"
  
  #Schedule helper methods
  def weekday?(datetime)
    return datetime.monday?     |
           datetime.tuesday?    |
           datetime.wednesday?  |
           datetime.thursday?   |
           datetime.friday?
  end

  def weekend?(datetime)
    return datetime.saturday? | datetime.sunday?
  end
  
  # initialize local variable to detect changes
  old_response_string = "unset"
  
  while true
    
    date_and_time = DateTime.now.new_offset('-05:00')
    
    if weekday?(date_and_time)  
      if ( (date_and_time.hour > 9) & (date_and_time.hour < 18) )
        response_string = "mike is at work"
        user = "mike"
        status = "work"
      else
        response_string = "mike is at home"
        user = "mike"
        status = "home"
      end
    elsif date_and_time.sunday?
      if ( (date_and_time.hour > 8) & (date_and_time.hour < 12) )
        response_string = "mike is at church"
        user = "mike"
        status = "church"
      end
    else
      response_string = "mike is at home"
      user = "mike"
      status = "home"
    end
    
    # if date_and_time.sec % 15 == 0
    #   response_string = "#{date_and_time.sec} secs"
    # end
    
    
    
    if response_string != old_response_string
      puts "It's #{date_and_time}"
      puts response_string
      update_frontend(user,status)
    end
    
    old_response_string = response_string
  
  end
end


  


#####################################
### Begin Sinatra framework logic ###
#####################################

before do
  #initialize options for input validation
  @users = $all_user_states.keys
  @possible_locations = ['work','home','church','school']
  @possible_states = ['entered', 'exited']
end

get '/' do
  "Welcome to this FC instance, powered by Sinatra v1.4.6.<br>The system time is #{Time.now}"
end

get '/status' do
  "#{$all_user_states}"
end


get '/api-update/gps/:user/:location/:enteredOrExited/:transaction_time' do
  #parse parameters
  user = params[:user]
  location = params[:location]
  enteredOrExited = params[:enteredOrExited]
  transaction_time = params[:transaction_time]
  
  #input validation
  if !@users.include?(user)
    halt 403, "Invalid user.  Only the following are handled: #{@users}"
  end
  
  if !@possible_locations.include?(location)
    halt 403, "Invalid location.  Only the following are handled: #{@possible_locations}"
  end
  
  if !@possible_states.include?(enteredOrExited)
    halt 403, "Invalid state.  Only the following are handled: #{@possible_states}"
  end
  
  
  #implement special conditions
  if transaction_time == 'now'
    transaction_time = Time.now
  end
  
  
  
  # return HTML
  if enteredOrExited == "exited"
    update_frontend(user,"traveling")
    "#{user.capitalize} is traveling from #{location}"
  else
    update_frontend(user,location)
    "#{user.capitalize} #{enteredOrExited} #{location} on #{transaction_time}"
  end

end

get '/api-update/cal/:user/:event_title/:event_start/:event_end' do
  # parse input parameters
  user        = params[:user]
  event_title = params[:event_title]
  event_start = params[:event_start]
  event_end   = params[:event_end]
  
  puts params
  event_start = DateTime.parse(event_start)
  event_end = DateTime.parse(event_end)
  puts event_start
  puts event_end
  
  "Calendar update recived<br>#{params}"
end
