#--------------------------------------------------------------------------
# Copyright (c) Microsoft Open Technologies, Inc.
# All Rights Reserved.  Licensed under the Apache License, Version 2.0.
# See License.txt in the project root for license information.
#--------------------------------------------------------------------------
require 'log4r'

module VagrantPlugins
  module WinAzure
    module Action
      class OSType
        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new('vagrant_azure::action::os_type')
        end

        def call(env)

          unless env[:machine].config.vm.guest
            env[:ui].info 'Determining OS Type By Image of ' + env[:machine].provider_config.vm_image
			      image = env[:azure_vm_image_service].send(:list_virtual_machine_images).select { |x| x.name.downcase == env[:machine].provider_config.vm_image.downcase }.first
			      env[:ui].error 'The virtual machine image source is not valid.' unless image
            guest_os_type = image.os_type
            env[:machine].config.vm.guest = guest_os_type && guest_os_type.downcase.to_sym
            if env[:machine].config.vm.guest == :windows && env[:machine].config.vm.communicator.nil?
              env[:machine].config.vm.communicator = :winrm
            end
            env[:ui].info "OS Type is #{guest_os_type}"
          end

          @app.call(env)
        end
      end
    end
  end
end
