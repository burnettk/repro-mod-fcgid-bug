class WorkersController < ApplicationController
  def index
    render text: `ps aux | grep dispatch | grep -v grep | wc -l`
  end
end
