require "mechanize"

class Event
  attr_accessor :title
  attr_accessor :sd_link
  attr_accessor :hd_link
  attr_accessor :description
end

ids = %w{101 102 103 104 105 106 107 108 112 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 301 302 303 304 306 401 402 403 404 405 406 407 408 409 410 411 412 413 414 501 502 503 504 505 506 507 508 509 510 511 602 603 604 605 606 607 608 609 610 701 702 703 704 705 706 707 708 709 710 711 712 713 714 715 717 718 719 720 801 802 803 804 805}

link_template = "https://developer.apple.com/videos/wwdc/2015/?id=IDENTIFICATOR"

mechanize = Mechanize.new
events = []

ids.each do |id|
  event = Event.new
  
  link = link_template.gsub(/IDENTIFICATOR/, id)
  page = mechanize.get(link)
  
  event.title = page.search("h3").text
  
  page.search("li a").each do |link|
    event.hd_link = link.attribute("href").value if link.text == "HD"
    event.sd_link = link.attribute("href").value if link.text == "SD"
  end
  
  event.description = page.search("section p").last.text
  
  events << event
end

item_template = <<-ITEM
<item>
	<title>TITLE</title>
	<itunes:subtitle>DESCRIPTION</itunes:subtitle>
	<itunes:summary>DESCRIPTION</itunes:summary>
	<enclosure url="LINK" type="video/quicktime"/>
	<guid>LINK</guid>
	<pubDate>Tue, 09 Jun 2015 10:00:00 +0000</pubDate>
</item>
ITEM

hd_items = ""
sd_items = ""

events.each do |event|
  hd_items << item_template
    .gsub("TITLE", event.title)
    .gsub("DESCRIPTION", event.description)
    .gsub("LINK", event.hd_link)

  sd_items << item_template
    .gsub("TITLE", event.title)
    .gsub("DESCRIPTION", event.description)
    .gsub("LINK", event.sd_link) 
    
end

channel_template = <<-CHANNEL
<?xml version="1.0"?>
<rss xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
	<channel>
		<title>WWDC 2015 Session Videos - Apple Developer</title>
		<description>WWDC 2015 Session Videos - Apple Developer</description>
		<link>https://developer.apple.com/videos/wwdc/2015/</link>
		<language>en-US</language>
		<itunes:complete>yes</itunes:complete>
		<itunes:author>Ondra Beneš</itunes:author>
		<itunes:explicit>clean</itunes:explicit>
		<itunes:image href="https://devimages.apple.com.edgekey.net/videos/images/videos-wwdc2015-banner.png"/>
    ITEMS
  </channel>
</rss>
CHANNEL

hd_channel = channel_template.gsub("ITEMS", hd_items)
sd_channel = channel_template.gsub("ITEMS", sd_items)

File.open("wwdc2015-hd.rss", "w").write(hd_channel)
File.open("wwdc2015-sd.rss", "w").write(sd_channel)