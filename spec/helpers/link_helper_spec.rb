require "rails_spec_helper"
require "./app/helpers/link_helper"

describe LinkHelper do
  include RSpecHtmlMatchers

  describe "#external_link_to" do
    it "creates a link with a _blank target if it links outside gradecraft" do
      link = helper.external_link_to("blah", "http://bacon.com")
      expect(link).to have_tag("a", with: { target: "_blank" })
    end

    it "does not create a link with a _blank target if it links inside gradecraft" do
      link = helper.external_link_to("blah", "http://gradecraft.com/somewhere")
      expect(link).to_not include("target")
    end

    it "does not override the target attribute if it's specified" do
      link = helper.external_link_to("blah", "http://bacon.com", target: "_parent")
      expect(link).to have_tag("a", with: { target: "_parent" })
    end

    context "with content from a block" do
      it "creates a link with a _blank target if it links outside gradecraft" do
        link = helper.external_link_to("http://bacon.com") { "blah" }
        expect(link).to have_tag("a", with: { target: "_blank" })
      end

      it "does not override the target attribute if it's specified" do
        link = helper.external_link_to("http://bacon.com", target: "_parent") { "blah" }
        expect(link).to have_tag("a", with: { target: "_parent" })
      end

      it "does not create a link with a _blank target if it links inside gradecraft" do
        link = helper.external_link_to("http://gradecraft.com/somewhere") { "blah" }
        expect(link).to_not include("target")
      end
    end
  end

  describe "#external_link?" do
    it "is not external if there is no link to check" do
      expect(helper.external_link?(nil)).to eq false
    end

    it "is external if it's not a part of the gradecraft domain" do
      link = "http://example.org"
      expect(helper.external_link?(link)).to eq true
    end

    it "is not external if it's a relative url" do
      link = "/users"
      expect(helper.external_link?(link)).to eq false
    end

    it "is not external if it's for localhost" do
      link = "http://localhost:5000"
      expect(helper.external_link?(link)).to eq false
    end

    it "is not external if it's an invalid url" do
      link = "blah^^^test"
      expect(helper.external_link?(link)).to eq false
    end

    it "is not external if it's part of the gradecraft domain" do
      link = "http://gradecraft.com"
      expect(helper.external_link?(link)).to eq false
    end

    it "is not external if it's part of the gradecraft domain with a www subdomain" do
      link = "http://www.gradecraft.com"
      expect(helper.external_link?(link)).to eq false
    end

    it "is not external if it's part of the gradecraft domain with a subdomain" do
      link = "http://blah.gradecraft.com"
      expect(helper.external_link?(link)).to eq false
    end

    it "is not external if it's https and part of the gradecraft domain" do
      link = "https://gradecraft.com"
      expect(helper.external_link?(link)).to eq false
    end

    it "is not external if it is part of the gradecraft domain and doesn't have a scheme" do
      link = "gradecraft.com"
      expect(helper.external_link?(link)).to eq false
    end

    it "is external if it's a mailto link" do
      link = "mailto:test@example.com"
      expect(helper.external_link?(link)).to eq true
    end
  end

  describe "#omission_link_to" do
    let(:content) { "Bacon ipsum dolor amet corned beef turducken cupim beef ribs ribeye, salami picanha frankfurter ham leberkas pancetta. Ham hock tongue tenderloin turducken ham jowl." }

    it "creates a link with content that has omissions for content with more than 50 characters" do
      link = helper.omission_link_to(content, "http://bacon.com")
      expect(link).to have_tag("a", text: "#{content[0..47]}...")
    end

    it "does not indicate a continuation if it falls below the limit" do
      content = "I ❤️  Bacon"
      link = helper.omission_link_to(content, "http://bacon.com")
      expect(link).to have_tag("a", text: content)
    end

    it "can be limited by an option" do
      link = helper.omission_link_to(content, "http://bacon.com", limit: 25)
      expect(link).to have_tag("a", text: "#{content[0..22]}...", without: { limit: "25" })
    end

    it "can be have a different indicator other than an elipsis" do
      indicator = "🍴 🍽"
      link = helper.omission_link_to(content, "http://bacon.com", indicator: indicator)
      expect(link).to have_tag("a", text: "#{content[0..47]}#{indicator}", without: { indicator: indicator })
    end

    it "moves the original content to the title" do
      link = helper.omission_link_to(content, "http://bacon.com")
      expect(link).to have_tag("a", with: { "title" => content })
    end

    context "with content from a block" do
      it "creates a link with content that has omissions for content with more than 50 characters" do
        link = helper.omission_link_to("http://bacon.com") do content end
        expect(link).to have_tag("a", text: "#{content[0..47]}...")
      end

      it "can be limited by an option" do
        link = helper.omission_link_to("http://bacon.com", limit: 25) do content end
        expect(link).to have_tag("a", text: "#{content[0..22]}...", without: { limit: "25" })
      end

      it "does not indicate a continuation if it falls below the limit" do
        content = "I ❤️  Bacon"
        link = helper.omission_link_to("http://bacon.com") do content end
        expect(link).to have_tag("a", text: content)
      end

      it "moves the original content to the title" do
        link = helper.omission_link_to("http://bacon.com") do content end
        expect(link).to have_tag("a", with: { "title" => content })
      end
    end
  end

  describe "#sanitize_external_links" do
    let(:content) { "<p>This is some content for <a href='http://example.org'>External</a>" }

    it "adds a target to all external links" do
      sanitized = helper.sanitize_external_links content
      expect(sanitized).to eq "<p>This is some content for <a href=\"http://example.org\" target=\"_blank\">External</a></p>"
    end
  end
end
