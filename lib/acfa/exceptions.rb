module Acfa::Exceptions
  class AcfaError < StandardError; end

  class Acfa::Exceptions::InvalidArchivesSpaceResourceUri < AcfaError; end
  class Acfa::Exceptions::InvalidEadXml < AcfaError; end
end
