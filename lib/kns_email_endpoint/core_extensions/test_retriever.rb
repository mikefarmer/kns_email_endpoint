# Mail::TestRetriever additional methods
require 'mail'
module Mail
  class TestRetriever
    def delete_all
      @@emails = []
    end

    remove_method :find

    # Fix a bug in the find method when only returning a single email
    def find(options = {}, &block)
      options[:count] ||= :all
      options[:order] ||= :asc
      options[:what] ||= :first
      emails = @@emails.dup
      emails.reverse! if options[:what] == :last
      emails = case count = options[:count]
               when :all then emails
               # when 1 then emails.first
               when Fixnum then emails[0, count]
               else
                 raise 'Invalid count option value: ' + count.inspect
               end
      if options[:what] == :last && options[:order] == :asc || options[:what] == :first && options[:order] == :desc
        emails.reverse!
      end
      emails.each { |email| email.mark_for_delete = true } if options[:delete_after_find]

      if block_given?
        emails.each { |email| yield email }
      else
        emails
      end.tap do |results|
        emails.each { |email| @@emails.delete(email) if email.is_marked_for_delete? } if options[:delete_after_find]
      end
      return emails.size == 1 && options[:count] == 1 ? emails.first : emails
    end
    
  end
end

