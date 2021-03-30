module Intrigue
  module Ident
    module Check
      class Apache < Intrigue::Ident::Check::Base
        def generate_checks(url)
          [ # Apache HTTP Server Test Page
            {
              type: "fingerprint",
              category: "application",
              tags: ["Administrative", "WebServer", "Database"],
              vendor: "Apache",
              product: "Ambari",
              description: "page title",
              version: nil,
              match_type: :content_body,
              match_content: /<title>Ambari<\/title>/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Coyote",
              description: "Apache Coyote application server - server header",
              version: nil,
              match_type: :content_headers,
              match_content: /server:\ Apache[-\s]Coyote/i,
              dynamic_version: lambda { |x|
                _first_header_capture(x, /server: Apache[-\s]Coyote\/(.*)/i)
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Groovy",
              description: "Groovy error page",
              match_type: :content_body,
              version: nil,
              match_content: /Error processing GroovyPageView:/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            # The requested URL /doesntexist-123 was not found on this server.</p>\n<hr>\n
            # <address>Apache/2.2.15 (Red Hat) Server at jasper.emory.edu Port 443</address>
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "HTTP Server",
              description: "test page title",
              version: nil,
              match_type: :content_body,
              match_content: /<address>Apache\/([\d\.]+).*Server at.*<\/address>/i,
              dynamic_version: lambda { |x|
                _first_body_capture(x, /<address>Apache\/([\d\.]+).*Server at.*<\/address>/i)
              },
              paths: [{ path: "#{url}/doesntexist-123", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "HTTP Server",
              description: "test page title",
              version: nil,
              match_type: :content_title,
              match_content: /Apache HTTP Server Test Page/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "HTTP Server",
              description: "Apache server header w/o version",
              version: nil,
              match_type: :content_headers,
              match_content: /^server: Apache$/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "HTTP Server",
              description: "Apache web server - server header - with versions",
              version: nil,
              match_type: :content_headers,
              match_content: /^server:.*Apache\/([\d\.]*)/i,
              dynamic_version: lambda { |x|

                # check for backported OS type
                backported = false
                backported = true if _first_header_match(x, /^server:.*\(CentOS\).*$/i)
                backported = true if _first_header_match(x, /^server:.*\(Red Hat\).*$/i)
                backported = true if _first_header_match(x, /^server:.*\(Red Hat Enterprise Linux\).*$/i)

                # grab the version
                version = _first_header_capture(x, /server:.*Apache\/([\d\.]*)/i)

                # return a version string that indicates we can't do inference
                return "#{version} (Backported)" if backported

                # otherwise just return the version
                version
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "HTTP Server",
              description: "Apache web server - server header - no version",
              version: nil,
              match_type: :content_headers,
              match_content: /^server:\ Apache$/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "HTTP Server",
              description: "Apache generic error",
              version: nil,
              match_type: :content_body,
              match_content: /The server encountered an internal error or misconfiguration and was unable to complete your request./i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "HTTP Server",
              description: "Apache default page (Ubuntu)",
              version: nil,
              match_type: :content_title,
              match_content: /^Apache2 Ubuntu Default Page: It works$/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
              issues: ["default_web_server_page_exposed"],
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Library"],
              vendor: "Apache",
              product: "mod_auth_kerb",
              description: "server header",
              version: nil,
              match_type: :content_headers,
              match_content: /^.*mod_auth_kerb\/.*$/i,
              dynamic_version: lambda { |x|
                _first_header_capture(x, /^.*mod_auth_kerb\/([\w\d\.\-]*)\s.*$/i)
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Library"],
              vendor: "Apache",
              product: "mod_bwlimited",
              description: "server header",
              version: nil,
              match_type: :content_headers,
              match_content: /^.*mod_bwlimited\/.*$/i,
              dynamic_version: lambda { |x|
                _first_header_capture(x, /^.*mod_bwlimited\/([\w\d\.\-]*)\s.*$/i)
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Library"],
              vendor: "Apache",
              product: "mod_fcgid",
              description: "server header",
              version: nil,
              match_type: :content_headers,
              match_content: /^.*mod_fcgid\/.*$/i,
              dynamic_version: lambda { |x|
                _first_header_capture(x, /^.*mod_fcgid\/([\w\d\.\-]*)\s.*$/i)
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Library"],
              vendor: "Apache",
              product: "tomcat_jk_connector",
              description: "server header",
              version: nil,
              match_type: :content_headers,
              match_content: /^.*mod_jk\/.*$/i,
              dynamic_version: lambda { |x|
                _first_header_capture(x, /^.*mod_jk\/([\w\d\.\-]*)\s.*$/i)
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Library"],
              vendor: "Apache",
              product: "mod_perl",
              description: "server header",
              version: nil,
              match_type: :content_headers,
              match_content: /^.*mod_perl\/.*$/i,
              dynamic_version: lambda { |x|
                _first_header_capture(x, /^.*mod_perl\/([\w\d\.\-]*)\s.*$/i)
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Library"],
              vendor: "Apache",
              product: "mod_ssl",
              description: "server header",
              version: nil,
              match_type: :content_headers,
              match_content: /^.*mod_ssl\/.*$/i,
              dynamic_version: lambda { |x|
                _first_header_capture(x, /^.*mod_ssl\/([\w\d\.\-]*)\s.*$/i)
              },
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["WebServer"],
              vendor: "Apache",
              product: "PivotalWebServer",
              description: "server header",
              version: nil,
              match_type: :content_headers,
              match_content: /^server: Apache PivotalWebServer$/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Sling",
              references: ["https://sling.apache.org/"],
              description: "Apache Sling™ is a framework for RESTful web-applications based on an extensible content tree. also note that this may be related to apache experience manager",
              version: nil,
              match_type: :content_body,
              match_content: /<address>Apache Sling<\/address>/i,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Tomcat",
              description: "Tomcat Application Server",
              match_type: :content_title,
              version: 6,
              match_content: /Tomcat 6 Welcome Page/,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Tomcat",
              description: "Tomcat Application Server",
              match_type: :content_body,
              version: nil,
              match_content: /this is the default Tomcat home page/,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Tomcat",
              description: "Tomcat Application Server",
              match_type: :content_body,
              version: nil,
              match_content: /If you're seeing this, you've successfully installed Tomcat. Congratulations/,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Tomcat",
              description: "Tomcat Application Server",
              match_type: :content_body,
              version: nil,
              match_content: /this is the default Tomcat home page/,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Tomcat",
              description: "Tomcat Application Server",
              match_type: :content_title,
              version: nil,
              match_content: /Apache Tomcat/,
              dynamic_version: lambda { |x|
                _first_body_capture(x, /<title>(.*)<\/title>/, ["Apache Tomcat/", " - Error report"])
              },
              paths: [
                { path: "#{url}", follow_redirects: true },
                { path: "#{url}/doesntexist-123", follow_redirects: true },
              ],
              inference: true,
            },
            {
              type: "fingerprint",
              require_product: "NetWeaver",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Tomcat",
              description: "Netweaver tomcat error page",
              match_type: :content_body,
              version: nil,
              match_content: /Apache Tomcat\//,
              dynamic_version: lambda { |x|
                _first_body_capture(x, /Apache Tomcat\/([\d\.]+)/)
              },
              paths: [{ path: "#{url}/irj/portal", follow_redirects: true }],
              inference: true,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Traffic Server",
              description: "header",
              match_type: :content_headers,
              version: nil,
              match_content: /^server: ATS$/,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "Traffic Server",
              description: "header",
              match_type: :content_headers,
              version: nil,
              match_content: /^via:.*ApacheTrafficServer.*$/,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "NiFi",
              description: "Shortcut icon in content body",
              match_type: :content_body,
              version: nil,
              match_content: /<link rel="shortcut icon" href="images\/nifi16.ico"\/>/,
              paths: [{ path: "#{url}", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Application Server"],
              vendor: "Apache",
              product: "NiFi",
              description: "Shortcut icon in content body",
              match_type: :content_body,
              require_product: "NiFi",
              dynamic_version: lambda { |x|
                _first_body_capture(x, /"version":"([\d\.]+)"/i)
              },
              match_content: /{"about":{"title":"NiFi"/,
              paths: [{ path: "#{url}/../nifi-api/flow/about", follow_redirects: true }],
              inference: false,
            },
            {
              type: "fingerprint",
              category: "application",
              tags: ["Platform"],
              vendor: "Apache",
              product: "Solr",
              description: "Main url redirect",
              match_logic: :all,
                matches: [
                  {
                    match_type: :content_code,
                    match_content: 302,
                  },
                  {
                    match_type: :content_headers,
                    match_content: /Location: http(s?):\/\/[a-zA-Z0-9\-\.\:]+\/solr/i,
                  }
                ],
                paths: [ 
                  { path: "#{url}",
                    follow_redirects: false
                  }
                ],
              inference: false
            }
          ]
        end
      end
    end
  end
end
