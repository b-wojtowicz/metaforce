module Metaforce
  module Metadata
    class Client
      module CRUD

        # Public: Create metadata
        #
        # Examples
        #
        #   client._create(:apex_page, :full_name => 'TestPage', label: 'Test page', :content => '<apex:page>foobar</apex:page>')
        def _create_metadata(type, metadata={})
          type = type.to_s.camelize
          request :create_metadata do |soap|
            soap.body = {
              :metadata => prepare(metadata)
            }.merge(attributes!(type))
          end
        end

        # Public: Delete metadata
        #
        # Examples
        #
        #   client._delete(:apex_component, 'Component')
        def _delete_metadata(type, *args)
          type = type.to_s.camelize
          metadata = args.map { |full_name| {:full_name => full_name} }
          request :delete_metadata do |soap|
            soap.body = {
              :metadata => metadata
            }.merge(attributes!(type))
          end
        end

        # Public: Update metadata
        #
        # Examples
        #
        #   client._update(:apex_page, 'OldPage', :full_name => 'TestPage', :label => 'Test page', :content => '<apex:page>hello world</apex:page>')
        def _update_metadata(type, current_name, metadata={})
          type = type.to_s.camelize
          request :update_metadata do |soap|
            soap.body = {
              :metadata => {
                :current_name => current_name,
                :metadata => prepare(metadata),
                :attributes! => { :metadata => { 'xsi:type' => "ins0:#{type}" } }
              }
            }
          end
        end

        def _rename_metadata(type, metadata = {})
          type = type.to_s.camelize
          request :rename_metadata do |soap|
            soap.body = {
                :type => type
            }.merge(metadata)
          end
        end

        def create_metadata(*args)
          Job::CRUD.new(self, :_create_metadata, args)
        end

        def update_metadata(*args)
          Job::CRUD.new(self, :_update_metadata, args)
        end

        def delete_metadata(*args)
          Job::CRUD.new(self, :_delete_metadata, args)
        end

        def rename_metadata(*args)
          Job::CRUD.new(self, :_rename_metadata, args)
        end

      private

        def attributes!(type)
          {:attributes! => { 'ins0:metadata' => { 'xsi:type' => "ins0:#{type}" } }}
        end

        # Internal: Prepare metadata by base64 encoding any content keys.
        def prepare(metadata)
          metadata = Array[metadata].compact.flatten
          metadata.each { |m| encode_content(m) }
          metadata
        end

        # Internal: Base64 encodes any :content keys.
        def encode_content(metadata)
          metadata[:content] = Base64.encode64(metadata[:content]) if metadata.has_key?(:content)
        end

      end
    end
  end
end
