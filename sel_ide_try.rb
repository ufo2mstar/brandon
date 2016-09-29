require "json"
require "selenium-webdriver"
require "rspec"
include RSpec::Expectations

describe "PhirstWikiTest" do

  before(:each) do
    @driver = Selenium::WebDriver.for :firefox
    @base_url = "http://change-this-to-the-site-you-are-testing/"
    @accept_next_alert = true
    @driver.manage.timeouts.implicit_wait = 30
    @verification_errors = []
  end

  after(:each) do
    @driver.quit
    @verification_errors.should == []
  end

  it "test_phirst_wiki" do
    (@driver.title).should == "Wikipedia - Wikipedia, the free encyclopedia"
    @driver.find_element(:link, "Wikipedia").click
    @driver.find_element(:link, "Wikipedia").click
    @driver.find_element(:css, "p > a.mw-redirect").click
    @driver.find_element(:css, "p > a.mw-redirect").click
    !60.times{ break if (@driver.title == "Online encyclopedia - Wikipedia, the free encyclopedia" rescue false); sleep 1 }
    (@driver.find_element(:css, "h2").text).should == "Contents"
    @driver.get "https://en.wikipedia.org/wiki/Main_Page"
    (@driver.find_element(:css, "td > div").text).should == "Welcome to Wikipedia,"
  end

  def element_present?(how, what)
    @driver.find_element(how, what)
    true
  rescue Selenium::WebDriver::Error::NoSuchElementError
    false
  end

  def alert_present?()
    @driver.switch_to.alert
    true
  rescue Selenium::WebDriver::Error::NoAlertPresentError
    false
  end

  def verify(&blk)
    yield
  rescue ExpectationNotMetError => ex
    @verification_errors << ex
  end

  def close_alert_and_get_its_text(how, what)
    alert = @driver.switch_to().alert()
    alert_text = alert.text
    if (@accept_next_alert) then
      alert.accept()
    else
      alert.dismiss()
    end
    alert_text
  ensure
    @accept_next_alert = true
  end
end
