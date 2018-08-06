defmodule Squeeze.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Squeeze.Repo

  alias Squeeze.Accounts.{User, Credential}

  @doc """
  Creates a guest user account. All visitors are assigned an account to help
  with onboarding and preferences.

  ## Examples

  iex> create_guest_user()
  {:ok, %User{}}
  """
  def create_guest_user() do
    create_user()
  end

  @doc """
  Gets or creates a user based on their credentials.

  ## Examples

  iex> get_or_create_user_by_credential(%{field: field})
  {:ok, %User{}}

  iex> get_or_create_user_by_credential(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def get_or_create_user_by_credential(attrs \\ %{}) do
    %{credential: %{provider: provider, uid: uid}} = attrs
    case get_credential(provider, uid) do
      nil -> create_user(attrs)
      credential -> {:ok, credential.user}
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload(:credential)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Gets a single credential by provider and uid.

  Returns nil if Credential does not exist.

  ## Examples

      iex> get_credential("strava", 1)
      %Credential{}

      iex> get_credential("strava", 2)
      nil

  """
  def get_credential(provider, uid) do
    Credential
    |> Repo.get_by(provider: provider, uid: uid)
    |> Repo.preload(:user)
  end
end
