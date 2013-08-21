# Copyright (c) <year> <copyright holder>.
# All rights reserved.

# Redistribution and use in source and binary forms are permitted
# provided that the above copyright notice and this paragraph are
# duplicated in all such forms and that any documentation,
# advertising materials, and other materials related to such
# distribution and use acknowledge that the software was developed
# by the <organization>.  The name of the
# <organization> may not be used to endorse or promote products derived
# from this software without specific prior written permission.
# THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

actions :create, :update

# Depending on whether you are creating or updating will determine what 
# fields are required or not.  Update requires tracker_id, title and 
# description.  Update only requires the artifact_id.

attribute :teamforge_url,		:kind_of => String, 	:required => true
attribute :teamforge_username,	:kind_of => String, 	:required => true
attribute :teamforge_password, 	:kind_of => String, 	:required => true
attribute :status,				:kind_of => String,		:required => true
attribute :priority,			:kind_of => Integer, 	:default => 5, 		:regex => /[1-5]/
attribute :estimated_hours,		:kind_of => Integer, 	:default => 0		
attribute :tracker_id,			:kind_of => String  	# required for create action
attribute :title, 				:kind_of => String 		# required for create action	
attribute :description, 		:kind_of => String		# required for create action	
attribute :artifact_id,			:kind_of => String		# required for update action
attribute :comment,				:kind_of => String
