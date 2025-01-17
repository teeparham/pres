# frozen_string_literal: true

module Pres
  module Presents
    private

    # Wrap an object or collection of objects with a presenter class.
    #
    # object    - A ruby object. May be nil.
    # presenter - A Presenter class (optional)
    # args      - optional hash / kwargs passed to the presenter
    #
    # An instance of a presenter class is created. The class is
    # one of the following:
    # - the `presenter` argument
    # - `Pres::Presenter` if object is nil
    # - object.presenter_class (if that method is defined)
    # - the default presenter class for the object
    #   (for example: User -> UserPresenter)
    #
    # Examples
    #
    # user = User.new
    # present(user, cool: true)
    # => #<UserPresenter object: #<User> ...>
    #
    # user = User.new
    # present(user) do |up|
    #   up.something
    # end
    # up => #<UserPresenter object: #<User> ...>
    #
    # user = User.new
    # present(user, presenter: NiceUserPresenter, cool: true)
    # => #<NiceUserPresenter object: #<User> ...>
    #
    # class User
    #   def presenter_class
    #     MyPresenter
    #   end
    # end
    # user = User.new
    # present(user)
    # => #<MyPresenter object: #<User> ...>
    #
    # present([user])
    # => [#<UserPresenter object: #<User> ...>]
    #
    # present(nil)
    # => [#<Presenter object: nil ...>]
    #
    # Returns a new Presenter object or array of new Presenter objects
    # Yields a new Presenter object if a block is given
    def present(object, presenter: nil, **kwargs)
      if object.respond_to?(:to_ary)
        object.map { |item| present(item, presenter:, **kwargs) }
      else
        presenter ||= presenter_klass(object)
        wrapper = presenter.new(object, view_context, **kwargs)
        block_given? ? yield(wrapper) : wrapper
      end
    end

    def presenter_klass(object)
      if object.nil?
        Presenter
      elsif object.respond_to?(:presenter_class)
        object.presenter_class
      else
        Object.const_get("#{object.class.name}Presenter")
      end
    end
  end
end
