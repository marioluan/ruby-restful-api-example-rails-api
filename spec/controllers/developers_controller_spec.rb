require "rails_helper"

# TODOs:
# - move common logic to shared examples
RSpec.describe DevelopersController, type: :controller do
  let(:valid_attributes) {
    {
      name: "Mario Luan",
      age: "26"
    }
  }

  let(:invalid_attributes) {
    {
      name: "",
      age: "-26"
    }
  }

  let(:valid_session) { {} }

  describe "GET #index" do
    let(:developers) { build_list :developer, Faker::Number.digit.to_i }
    let(:params) { nil }

    before do
      allow(Developer).to receive(:where).and_return(developers)
    end

    it "assigns fetched developers to @developers" do
      get :index, params: params, session: valid_session

      expect(assigns(:developers)).to eq developers
    end

    it "paginates the result" do
      expect_any_instance_of(DevelopersController).to receive(:paginate).with(json: developers)

      get :index, params: params, session: valid_session
    end

    context "when search_params are provided" do
      context "with :name" do
        let(:name) { Faker::Name.name }
        let(:params) { {name: name} }
        let(:search_params) { ActionController::Parameters.new(params).permit(:name, :age) }

        before do
          allow(Developer).to receive(:where).with(search_params).and_return(developers)
        end

        it "filters developers by :name" do
          expect(Developer).to receive(:where).with(search_params)

          get :index, params: params, session: valid_session
        end
      end

      context "with :age" do
        let(:age) { Faker::Number.digit }
        let(:params) { {age: age} }
        let(:search_params) { ActionController::Parameters.new(params).permit(:name, :age) }

        before do
          allow(Developer).to receive(:where).with(search_params).and_return(developers)
        end

        it "filters developers by :age" do
          expect(Developer).to receive(:where).with(search_params)

          get :index, params: params, session: valid_session
        end
      end
    end

    context "when search_params are not provided" do
      let(:params) { {} }
      let(:search_params) { ActionController::Parameters.new(params).permit(:name, :age) }

      before do
        allow(Developer).to receive(:where).with(search_params).and_return(developers)
      end

      it "fetches all developers" do
        expect(Developer).to receive(:where).with(search_params)

        get :index, params: params, session: valid_session
      end
    end
  end

  describe "GET #show" do
    let(:developer) { build :developer }
    let(:id) { "1" }

    before do
      allow(Developer).to receive(:find).with(id).and_return(developer)

      get :show, params: {id: id}, session: valid_session
    end

    after do
      get :show, params: {id: id}, session: valid_session
    end

    it "finds the developer by its :id" do
      expect_any_instance_of(DevelopersController).to receive(:set_developer)
    end

    it "assigns the requested developer as @developer" do
      expect(assigns(:developer)).to eq(developer)
    end

    it "renders the developer as :json" do
      expect_any_instance_of(DevelopersController).to receive(:render).with(json: developer)
    end
  end

  describe "POST #create" do
    let(:developer) { nil }
    let(:developer_params) { nil }

    before do
      allow(Developer).to receive(:new).with(developer_params).and_return(developer)
    end

    context "with valid params" do
      let(:developer) { build :developer }
      let(:params) { {name: developer.name, age: developer.age.to_s} }
      let(:developer_params) { ActionController::Parameters.new(params).permit(:name, :age) }

      before do
        allow(developer).to receive(:save).and_return(true)
      end

      it "assigns a new developer as @developer" do
        expect(Developer).to receive(:new).with(developer_params)

        post :create, params: {developer: params}, session: valid_session

        expect(assigns(:developer)).to eq developer
      end

      it "tries to save the developer" do
        expect(developer).to receive(:save)

        post :create, params: {developer: params}, session: valid_session
      end

      it "renders it" do
        expect_any_instance_of(DevelopersController).to receive(:render).with(json: developer, status: :created, location: developer)

        post :create, params: {developer: params}, session: valid_session
      end
    end

    context "with invalid params" do
      let(:developer) { build :developer, :invalid }
      let(:params) { {name: developer.name, age: developer.age.to_s} }
      let(:developer_params) { ActionController::Parameters.new(params).permit(:name, :age) }

      before do
        allow(developer).to receive(:save).and_return(false)
      end

      it "assigns a new developer as @developer" do
        expect(Developer).to receive(:new).with(developer_params)

        post :create, params: {developer: params}, session: valid_session

        expect(assigns(:developer)).to eq developer
      end

      it "tries to save the developer" do
        expect(developer).to receive(:save)

        post :create, params: {developer: params}, session: valid_session
      end

      it "renders the errors found" do
        expect_any_instance_of(DevelopersController).to receive(:render).with(json: developer.errors, status: :unprocessable_entity)

        post :create, params: {developer: params}, session: valid_session
      end
    end
  end

  describe "PUT #update" do
    let(:id) { Faker::Number.digit }
    let(:params) { nil }
    let(:developer) { nil }
    let(:developer_params) { nil }

    before do
      allow(Developer).to receive(:find).with(id).and_return(developer)
    end

    context "with valid params" do
      let(:developer) { build :developer }
      let(:params){ {name: developer.name, age: developer.age.to_s} }
      let(:developer_params) { ActionController::Parameters.new(params).permit(:name, :age) }

      before do
        allow(developer).to receive(:update).with(developer_params).and_return(true)
      end

      it "assigns the requested developer as @developer" do
        put :update, params: {id: id, developer: params}, session: valid_session
        expect(assigns(:developer)).to eq(developer)
      end

      it "tries to update the requested developer" do
        expect(developer).to receive(:update).with(developer_params)
        put :update, params: {id: id, developer: params}, session: valid_session
      end

      it "renders the developer" do
        expect_any_instance_of(DevelopersController).to receive(:render).with(json: developer)
        put :update, params: {id: id, developer: params}, session: valid_session
      end
    end

    context "with invalid params" do
      let(:developer) { build :developer, :invalid }
      let(:params){ {name: developer.name, age: developer.age.to_s} }
      let(:developer_params) { ActionController::Parameters.new(params).permit(:name, :age) }

      before do
        allow(developer).to receive(:update).with(developer_params).and_return(false)
      end

      it "assigns the requested developer as @developer" do
        put :update, params: {id: id, developer: params}, session: valid_session
        expect(assigns(:developer)).to eq(developer)
      end

      it "tries to update the requested developer" do
        expect(developer).to receive(:update).with(developer_params)
        put :update, params: {id: id, developer: params}, session: valid_session
      end

      it "renders the errors found" do
        expect_any_instance_of(DevelopersController).to receive(:render).with(json: developer.errors, status: :unprocessable_entity)
        put :update, params: {id: id, developer: params}, session: valid_session
      end
    end
  end

  describe "DELETE #destroy" do
    let(:developer){ create :developer }
    let(:id){ developer.id.to_s }
    let(:params) { {id: id} }

    before do
      allow(Developer).to receive(:find).with(id).and_return(developer)
    end

    it "destroys the requested developer" do
      expect(developer).to receive(:destroy)
      delete :destroy, params: params, session: valid_session
    end
  end

end
