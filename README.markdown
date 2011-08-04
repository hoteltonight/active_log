ActiveLog
=========
You need ActiveLog when you want to automagically create changelog of all activerecord changes in your rails app, asynchronously. It will keep track of all changes on attributes and as a bonus it can also record which user (session's current_user) made the change.

Example
-------

add "records\_active_log" to all models which needs to be logged
<pre><code>
class User < ActiveRecord::Base

  records_active_log

end
</code></pre>

You can access logs either by user or all...

<pre>
	>>u = User.first
	>>u.active_logs
	=> [...]
	
	or
	
	>> ActiveLog.all

</pre>

If you want to log along with information of currently logged in user then you should consider adding a before filter to application controller which sets ActiveLog.current = current_user

In addition, you can get the value of an attribute at a given time in the past by using the dynamic *_at_timestamp methods that get created for each model attribute.  For example:

<pre>
  >>u = User.first
  >>u.last_name_at_timestamp(1.week.ago)
</pre>

Copyright (c) 2010 Abhishek Parolkar, released under the MIT license
