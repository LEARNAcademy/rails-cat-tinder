class CatsController < ApplicationController
    def index
        cats = Cat.all
        render json: cats
    end
  
    def create
        cat = Cat.create(cat_params)
        if cat.valid?
            render json: cat
        else
            render json: cat.errors, status: :unprocessable_entity
        end
    end
    

    private
    # Handle strong parameters, so we are secure
    def cat_params
        params.require(:cat).permit(:name, :age, :enjoys)
    end
end
