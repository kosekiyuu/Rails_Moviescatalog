require 'test_helper'

class MoviesControllerTest < ActionController::TestCase
  setup do
    @movie = movies(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:movies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create movie" do
    assert_difference('Movie.count') do
      post :create, movie: { audio_bitrate: @movie.audio_bitrate, audio_channels: @movie.audio_channels, audio_codec: @movie.audio_codec, audio_sample_rate: @movie.audio_sample_rate, bitrate: @movie.bitrate, colorspace: @movie.colorspace, contributor: @movie.contributor, contributor_comment: @movie.contributor_comment, creation_time: @movie.creation_time, duration: @movie.duration, file_basename: @movie.file_basename, file_name: @movie.file_name, local_file_path: @movie.local_file_path, movie_title: @movie.movie_title, path: @movie.path, play_counts: @movie.play_counts, rating: @movie.rating, resolution: @movie.resolution, size: @movie.size, video_bitrate: @movie.video_bitrate, video_codec: @movie.video_codec }
    end

    assert_redirected_to movie_path(assigns(:movie))
  end

  test "should show movie" do
    get :show, id: @movie
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @movie
    assert_response :success
  end

  test "should update movie" do
    patch :update, id: @movie, movie: { audio_bitrate: @movie.audio_bitrate, audio_channels: @movie.audio_channels, audio_codec: @movie.audio_codec, audio_sample_rate: @movie.audio_sample_rate, bitrate: @movie.bitrate, colorspace: @movie.colorspace, contributor: @movie.contributor, contributor_comment: @movie.contributor_comment, creation_time: @movie.creation_time, duration: @movie.duration, file_basename: @movie.file_basename, file_name: @movie.file_name, local_file_path: @movie.local_file_path, movie_title: @movie.movie_title, path: @movie.path, play_counts: @movie.play_counts, rating: @movie.rating, resolution: @movie.resolution, size: @movie.size, video_bitrate: @movie.video_bitrate, video_codec: @movie.video_codec }
    assert_redirected_to movie_path(assigns(:movie))
  end

  test "should destroy movie" do
    assert_difference('Movie.count', -1) do
      delete :destroy, id: @movie
    end

    assert_redirected_to movies_path
  end
end
