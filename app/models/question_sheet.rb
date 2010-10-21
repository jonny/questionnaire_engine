require 'model_extensions'
# QuestionSheet represents a particular form
class QuestionSheet < ActiveRecord::Base
  set_table_name "#{Questionnaire.table_name_prefix}#{self.table_name}"
  
  has_many :pages, :dependent => :destroy, :order => 'number'
  # has_many :elements
  # has_many :questions
  has_many :answer_sheets
  scope :active, where(:archived => false)
  scope :archived, where(:archived => true)
  
  validates_presence_of :label
  validates_length_of :label, :maximum => 60, :allow_nil => true  
  validates_uniqueness_of :label
  
  before_destroy :check_for_answers

  
  # create a new form with a page already attached
  def self.new_with_page
    question_sheet = self.new(:label => next_label)
    question_sheet.pages.build(:label => 'Page 1', :number => 1)    
    question_sheet
  end
 
  def questions
    pages.collect(&:questions).flatten
  end
 
  def elements
    pages.collect(&:elements).flatten
  end
  
  # Pages get duplicated
  # Question elements get associated
  # non-question elements get cloned
  def duplicate
    new_sheet = QuestionSheet.new(self.attributes)
    new_sheet.label = self.label + ' - COPY'
    new_sheet.save(:validate => false)
    self.pages.each do |page|
      new_page = Page.new(page.attributes)
      new_page.question_sheet_id = new_sheet.id
      new_page.save(:validate => false)
      page.elements.each do |element|
        if !self.archived? && (element.is_a?(Question) || element.is_a?(QuestionGrid) || element.is_a?(QuestionGridWithTotal))
          PageElement.create(:element => element, :page => new_page)
        else
          element.duplicate(new_page)
        end
      end
    end
    new_sheet
  end
  
  
  private
  
  # next unused label with "Untitled form" prefix
  def self.next_label
    ModelExtensions.next_label("Untitled form", untitled_labels)
  end

  # returns a list of existing Untitled forms
  # (having a separate method makes it easy to mock in the spec)
  def self.untitled_labels
    QuestionSheet.find(:all, :conditions => %{label like 'Untitled form%'}).map {|s| s.label}
  end
  
  def check_for_answers
    
  end

end
