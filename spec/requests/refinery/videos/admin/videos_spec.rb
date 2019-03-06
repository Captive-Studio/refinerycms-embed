# encoding: utf-8
require "spec_helper"
Capybara.javascript_driver = :poltergeist


describe Refinery do
  describe 'Videos' do
    describe 'Admin' do
      describe 'videos', type: :feature do
        refinery_login

        describe 'videos list' do
          before(:each) do
            FactoryBot.create(:valid_video, :title => 'UniqueTitleOne')
            FactoryBot.create(:valid_video, :title => 'UniqueTitleTwo')
          end

          it "shows two items" do
            visit refinery.videos_admin_videos_path
            page.should have_content("UniqueTitleOne")
            page.should have_content("UniqueTitleTwo")
          end
        end

        describe "create", :js => true do
          before(:each) do
            visit refinery.videos_admin_videos_path
            click_link "Add New Video"
          end

          context "valid data for embed video" do
            it "should succeed" do
              click_link "Use embedded video"
              fill_in "video_title", :with => "Test Video"
              fill_in "video_embed_tag", :with => '<iframe src="http://player.vimeo.com/video/39432556" width="500" height="281" frameborder="0" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>'
              click_button "Save"

              page.should have_content("'Test Video' was successfully added.")
              Refinery::Videos::Video.count.should == 1
            end
          end

          context "valid data for file with url" do
            it "should succeed" do
              fill_in "video_title", :with => "Test Video"
              choose 'Use external source'
              fill_in 'video_video_files_attributes_0_external_url', :with => 'url'
              click_button "Save"
              page.should have_content("'Test Video' was successfully added.")
              Refinery::Videos::Video.count.should == 1
            end
          end

          context "valid data for file with file" do
            let(:video_path) { Refinery.roots('refinery/videos').join('spec/support/fixtures/video.flv') }

            it "should succeed" do
              fill_in "video_title", :with => "Test Video"
              file = File.join(Rails.root, 'spec/support/fixtures/video.flv')
              attach_file('video_video_files_attributes_0_file', video_path)
              click_button "Save"
              page.should have_content("'Test Video' was successfully added.")
              Refinery::Videos::Video.count.should == 1
            end
          end

        end

        describe "edit" do
          before(:each) { FactoryBot.create(:valid_video, :title => "Test Video") }

          it "should succeed" do
            visit refinery.videos_admin_videos_path
            within ".actions" do
              click_link "Edit this video"
            end
            fill_in "video_title", :with => "A different file_name"
            click_button "Save"
            page.should have_content("'A different file_name' was successfully updated.")
            page.should have_no_content("Test Video")
            page.should have_content("A different file_name")
          end
        end

        describe "destroy" do
          before(:each) { FactoryBot.create(:valid_video, :title => "UniqueTitleOne") }
          it "should succeed" do
            visit refinery.videos_admin_videos_path
            click_link "Remove this video forever"
            page.should have_content("'UniqueTitleOne' was successfully removed.")
            Refinery::Videos::Video.count.should == 0
          end
        end

        describe "insert video" do
          before(:each) do
            FactoryBot.create(:valid_video, :title => "Test Video1", :embed_tag => 'external_video1')
            FactoryBot.create(:valid_video, :title => "Test Video2", :embed_tag => 'external_video2')
          end

          it "should show list of available video" do
            visit refinery.insert_videos_admin_videos_path
            page.should have_content("Test Video1")
            page.should have_content("Test Video2")
          end
        end

      end
    end
  end
end
