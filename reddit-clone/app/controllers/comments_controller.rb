class CommentsController < ApplicationController

  def new

  end

  def create
    @comment = Comment.new(comment_params)
    @comment.author_id = current_user.id
    if @comment.save
      redirect_to post_url(@comment.post_id)
    else
      flash[:errors] = @comment.errors.full_messages
      redirect_to post_url(@comment.post_id)
    end
  end


  def comment_params
    params.require(:comment).permit(:content, :parent_comment_id, :post_id)

end
