require 'spec_helper'

describe Feed::Blog do

  subject { Feed::Blog.make_unsaved }

  describe "#info=" do

    context "when an rss and atom feed are available" do

      before do
        subject
          .should_receive(:open)
          .with('http://blog.example.com')
          .and_return { fixture 'blog.rss.html' }

        subject.info = 'blog.example.com'
      end

      its(:url) { should == 'http://blog.example.com/rss' }

    end

    context "when only an atom feed is available" do

      before do
        subject
          .should_receive(:open)
          .with('http://blog.example.com')
          .and_return { fixture 'blog.atom.html' }

        subject.info = 'blog.example.com'
      end

      its(:url) { should == 'http://blog.example.com/atom' }

    end

    context "when no feed is available" do

      before do
        subject
          .should_receive(:open)
          .with('http://blog.example.com')
          .and_return { fixture 'blog.no_feed.html' }

        subject.info = 'blog.example.com'
      end

      its(:url) { should be_nil }

    end

    context "when given feed doesn't start with http://" do

      before do
        @doc = mock
        Nokogiri.stub!(:parse).and_return{ @doc }
      end

      context "an absolute path" do
        before do
          @doc.should_receive(:css).with('link[rel=alternate]').and_return {
            [{'type' => 'rss', 'href' => '/feed.rss'}]
          }
        end

        it "should build the full url" do
          subject.info = 'example.com/blog'
          subject.url.should == 'http://example.com/feed.rss'
        end
      end

      context "a relative path" do
        before do
          @doc.should_receive(:css).with('link[rel=alternate]').and_return {
            [{'type' => 'rss', 'href' => 'feed.rss'}]
          }
        end

        it "should build the full url" do
          subject.info = 'example.com/blog'
          subject.url.should == 'http://example.com/blog/feed.rss'
        end
      end

    end


    context "when an rss feed is given" do

      before do
        subject
          .should_receive(:open)
          .with('http://blog.example.com/feed')
          .and_return { fixture 'feed.rss.xml' }

        subject.info = 'blog.example.com/feed'
      end

      its(:url) { should == 'http://blog.example.com/feed' }

    end

    context "when an atom feed is given" do

      before do
        subject
          .should_receive(:open)
          .with('http://blog.example.com/feed')
          .and_return { fixture 'feed.atom.xml' }

        subject.info = 'blog.example.com/feed'
      end

      its(:url) { should == 'http://blog.example.com/feed' }

    end

  end

end
