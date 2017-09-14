class ErrorsController < ApplicationController
  def not_found
    request.format = 'html'

    @title = 'ClientComm.org | Page not found (404)'

    respond_to do |format|
      format.any { render status: 404 }
    end
  end

  def internal_server_error
    @title = 'ClientComm | There has been a problem on our end (500)'

    render(status: 500)
  end
end
