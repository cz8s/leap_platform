raise SkipTest unless service?(:mx)

require 'json'

class Mx < LeapTest
  depends_on "Network"

  def setup
  end

  def test_01_Can_contact_couchdb?
    dbs = ["identities"]
    dbs.each do |db_name|
      couchdb_urls("/"+db_name, url_options).each do |url|
        assert_get(url) do |body|
          assert response = JSON.parse(body)
          assert_equal db_name, response['db_name']
        end
      end
    end
    pass
  end

  def test_02_Can_contact_couchdb_via_haproxy?
    if property('haproxy.couch')
      url = couchdb_url_via_haproxy("", url_options)
      assert_get(url) do |body|
        assert_match /"couchdb":"Welcome"/, body, "Request to #{url} should return couchdb welcome message."
      end
      pass
    end
  end

  def test_03_Are_MX_daemons_running?
    assert_running 'leap_mx'
    assert_running '/usr/lib/postfix/master'
    assert_running '/usr/sbin/unbound'
    pass
  end

  private

  def url_options
    {
      :username => property('couchdb_leap_mx_user.username'),
      :password => property('couchdb_leap_mx_user.password')
    }
  end

end
