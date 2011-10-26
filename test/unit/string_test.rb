require 'test_helper'

class StringTest < ActiveSupport::TestCase
  test "to channel name replace at and dots" do
    assert_equal "lorem_plus_123_at_acme_dot_org_dot_ar", "lorem+123@acme.org.ar".to_channel_name
  end
  
  test "remove protocol" do
    assert_equal "25526", "sms://25526".without_protocol
  end
  
  test "remove protocol when there is no protocol" do
    assert_equal "35352", "35352".without_protocol
    assert_equal "", "".without_protocol    
    assert_equal nil, nil.without_protocol
  end
end
