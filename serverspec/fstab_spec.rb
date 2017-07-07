require 'spec_helper'

describe fstab do
  it do
    should have_entry(
      :device => '/dev/sdc',
      :mount_point => '/opt/sonarqube/extensions/plugins',
      :type => 'ext4',
      :options => {
        :defaults => true,
        :noatime  => true,
      },
      :dump => 1,
      :pass => 1
    )
  end
end

