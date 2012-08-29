=begin
    Copyright 2010-2012 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

class Profile < ActiveRecord::Base

    DESCRIPTIONS_FILE = "#{Rails.root}/config/profile/attributes.yml"

    serialize :cookies, Hash
    serialize :custom_headers, Hash
    serialize :exclude, Array
    serialize :include, Array
    serialize :exclude_cookies, Array
    serialize :exclude_vectors, Array
    serialize :extend_paths, Array
    serialize :restrict_paths, Array
    serialize :modules, Array
    serialize :plugins, Hash
    serialize :redundant, Hash

    attr_accessible :name, :audit_cookies, :audit_cookies_extensively, :audit_forms,
                    :audit_headers, :audit_links, :authed_by, :auto_redundant,
                    :cookies, :custom_headers, :depth_limit, :exclude,
                    :exclude_binaries, :exclude_cookies, :exclude_vectors,
                    :extend_paths, :follow_subdomains, :fuzz_methods, :http_req_limit,
                    :include, :link_count_limit, :login_check_pattern, :login_check_url,
                    :max_slaves, :min_pages_per_instance, :modules, :plugins, :proxy_host,
                    :proxy_password, :proxy_port, :proxy_type, :proxy_username,
                    :redirect_limit, :redundant, :restrict_paths, :user_agent,
                    :description, :default

    def self.default
        self.where( default: true ).first
    end

    def self.unmake_default
        if p = self.default
            p.default = false
            p.save
        end
    end

    def make_default
        self.class.unmake_default
        self.default = true
        self.save
    end

    def default?
        !!self.default
    end

    def modules=( m )
        return super( ::FrameworkHelper.modules.keys ) if m == :all || m == :default
        super( m )
    end

    def modules_with_info
        modules.inject( {} ) { |h, name| h[name] = ::FrameworkHelper.modules[name]; h }
    end

    def has_modules?
        self.modules.any?
    end

    def has_plugins?
        self.plugins.any?
    end

    def plugins=( p )
        if p == :default
            c = ::FrameworkHelper.default_plugins.keys.inject( {} ) { |h, name| h[name] = {}; h }
            return super( c )
        end
        super( p )
    end

    def plugins_with_info
        plugins.keys.inject( {} ) { |h, name| h[name] = ::FrameworkHelper.plugins[name]; h }
    end

    def self.string_for( attribute, type = nil )
        @descriptions ||= YAML.load( IO.read( DESCRIPTIONS_FILE ) )

        case description = @descriptions[attribute.to_s]
            when String
                return if type != :description
                description
            when Hash
                description[type.to_s]
        end
    end

    def self.description_for( attribute )
        string_for( attribute, :description )
    end
    def description_for( attribute )
        self.class.description_for( attribute )
    end

    def self.notice_for( attribute )
        string_for( attribute, :notice )
    end
    def notice_for( attribute )
        self.class.notice_for( attribute )
    end

    def self.warning_for( attribute )
        string_for( attribute, :warning )
    end
    def warning_for( attribute )
        self.class.warning_for( attribute )
    end

end