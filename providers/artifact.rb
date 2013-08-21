# Copyright (c) 2013 Brent McConnell.
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

require 'savon'
# Add to savon for processing the multirefs in the TeamForge response
# Basically replaces just all `<arg href="#xyz"/>`-entries with the "real" value.
module NokogiriResponse
  def xml_body
    @xml_body ||= NokogiriResponse.create_doc_and_process_multirefs(self.to_xml)
  end
 
  def sayHello
  	return "hello amigo"
  end 

  private
    def self.create_doc_and_process_multirefs(xml)
      # find all references
      doc = Nokogiri::XML(xml)
      doc.css('[href]').select { |n| !n.blank? && n.attributes.size == 1 }.map { |n| n['href'] }.sort.uniq.each do |ref|
        ref_node = doc.css(ref).first
        unless ref_node.nil?
          doc.css("[href='#{ref}']").each do |node|
            ref_node.children.each { |child| node.add_child(child.clone) }
            ref_node.attributes.each { |name, value| node[name] = value unless ["id", "root"].include?(name) }
          end
          ref_node.remove # delete node from document
        end
      end
      doc.to_s
    end
end
Savon::Response.send(:include, NokogiriResponse)

class ResponseXMLParser

    def initialize (response_xml)
        @doc = Nokogiri::XML(response_xml)
    end

    def get_property(property)
        values = []
        @doc.xpath(property).each do |node|
            values << node.content
        end
        return values
    end
end

action :create do
	chef_gem "savon" do
   		action :install
	   	version "2.2.0"
 	end
	log	"Doing Create in #{new_resource.name}"
	artifact = create_tracker_artifact
	log "Artifact=#{artifact} created"
end

action :update do
	chef_gem "savon" do
   		action :install
	   	version "2.2.0"
 	end
	log "Doing Update of #{new_resource.name}"
	artifact = update_tracker_artifact
	log "Artifact=#{artifact} updated"
end

private

def get_tracker_wsdl_and_endpoint
	return "/ce-soap50/services/TrackerApp?wsdl", "/ce-soap50/services/TrackerApp"
end

def get_collabnet_wsdl_and_endpoint
	return "/ce-soap50/services/CollabNet?wsdl", "/ce-soap50/services/CollabNet"
end

def get_collabnet_service
	collabnet_wsdl, collabnet_endpoint = get_collabnet_wsdl_and_endpoint
	service = Savon.client(
			wsdl: @new_resource.teamforge_url + collabnet_wsdl, 
			endpoint: @new_resource.teamforge_url + collabnet_endpoint
		)
	return service
end

def get_tracker_service
	tracker_wsdl, tracker_endpoint = get_tracker_wsdl_and_endpoint
	service = Savon.client(
			wsdl: @new_resource.teamforge_url + tracker_wsdl,
			endpoint: @new_resource.teamforge_url + tracker_endpoint
		)
	return service
end

def get_collabnet_session
	collabnet_service = get_collabnet_service
	response = collabnet_service.call(:login, 
			message: {
				userName: @new_resource.teamforge_username,
				password: @new_resource.teamforge_password
			}
		)
	return response.to_hash[:login_response][:login_return]
end

def create_tracker_artifact
	tracker_service = get_tracker_service
	response = tracker_service.call(:create_artifact, 
			message: {
				sessionId: get_collabnet_session,
				trackerId: @new_resource.name,
				title: @new_resource.title,
				description: @new_resource.description,
				status: @new_resource.status,
				priority: @new_resource.priority,
				estimatedHours: @new_resource.estimated_hours
			}
		)
	return response.success?
end

def get_tracker_artifact(artifact_id)
	tracker_service = get_tracker_service
	artifact = tracker_service.call(:get_artifact_data, 
	    message: {
	        sessionId: get_collabnet_session, 
	        artifactId: artifact_id
	    }
	)
	return artifact
end

def update_tracker_artifact
	tracker_service = get_tracker_service
	artifact = get_tracker_artifact(@new_resource.name)
	if artifact.success?
		parser = ResponseXMLParser.new(artifact.xml_body)
		id = parser.get_property("//id").first
		status = parser.get_property("//status").first
		title = parser.get_property("//title").first
		description = parser.get_property("//description").first
		version = parser.get_property("//version").first
		priority = parser.get_property("//priority").first
		estimated_hours = parser.get_property("//estimatedHours").first
	end
	updated_artf = tracker_service.call(:set_artifact_data,
		message: {
			sessionId: get_collabnet_session,
			comment: @new_resource.comment,
			artifactData: {
				id: @new_resource.name,
				title: @new_resource.title || title,
				description: @new_resource.description || description,
				status: @new_resource.status || status,
				priority: @new_resource.priority || Integer(priority),
				estimatedHours: @new_resource.estimated_hours || Integer(estimated_hours),
				version: version
			}
		}
	)
end


