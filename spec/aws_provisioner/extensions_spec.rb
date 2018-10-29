describe "Language extensions" do
  describe "Symbol#camelize" do
    it "transforms a single word symbol" do
      expect(:example.camelize).to eq("Example")
    end

    it "camel cases two words or more seperated by underscores" do
      expect(:another_example.camelize).to eq("AnotherExample")
      expect(:another_silly_example.camelize).to eq("AnotherSillyExample")
    end
  end
end
