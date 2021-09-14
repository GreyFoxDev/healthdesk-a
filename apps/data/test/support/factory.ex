defmodule Data.Factory do
  @moduledoc """

  """
  use ExMachina.Ecto, repo: Data.Repo

  import Data.TestHelper, only: [phone_number: 0]

  alias Data.Schema.{
    Campaign,
    CampaignRecipient,
    ChildCareHour,
    ClassSchedule,
    Conversation,
    ConversationDisposition,
    ConversationMessage,
    Disposition,
    HolidayHour,
    Location,
    Member,
    MemberChannel,
    NormalHour,
    PricingPlan,
    Team,
    TeamMember,
    User,
    WifiNetwork
  }

  def campaign_factory do
    %Campaign{
      id: UUID.uuid4(),
      location_id: nil,
      campaign_name: "My Campaign",
      send_at: DateTime.utc_now()
    }
  end

  def campaign_recipient_factory do
    %CampaignRecipient{
      id: UUID.uuid4(),
      campaign_id: nil,
      recipient_name: "Bob Dobbs",
      phone_number: "000 555-1212"
    }
  end

  def child_care_hour_factory do
    %ChildCareHour{
      id: UUID.uuid4(),
      location_id: nil,
      day_of_week:
        Enum.random(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]),
      morning_open_at: "8:00 AM",
      morning_close_at: "12:00 PM",
      afternoon_open_at: "3:30 PM",
      afternoon_close_at: "7:30 PM",
      active: true
    }
  end

  def class_schedule_factory do
    %ClassSchedule{
      id: UUID.uuid4(),
      location_id: nil,
      date: ~D[2020-04-20],
      start_time: ~T[10:00:00],
      end_time: ~T[11:00:00],
      instructor: "Bob",
      class_type: "Power Yoga",
      class_category: "Strength",
      class_description: "A mean yoga class"
    }
  end

  def conversation_factory do
    %Conversation{
      id: UUID.uuid4(),
      location_id: nil,
      team_member_id: nil,
      original_number: phone_number(),
      status: "open",
      channel_type: "SMS",
      started_at: DateTime.utc_now()
    }
  end

  def conversation_disposition_factory do
    %ConversationDisposition{
      id: UUID.uuid4(),
      conversation_id: nil,
      disposition_id: nil
    }
  end

  def conversation_message_factory do
    %ConversationMessage{
      id: UUID.uuid4(),
      conversation_id: nil,
      phone_number: phone_number(),
      message: "Hello",
      sent_at: DateTime.utc_now()
    }
  end

  def disposition_factory do
    %Disposition{
      id: UUID.uuid4(),
      team_id: nil,
      disposition_name: sequence(:disposition_name, &"Disposition #{&1}"),
      is_system: false
    }
  end

  def holiday_hour_factory do
    %HolidayHour{
      id: UUID.uuid4(),
      location_id: nil,
      holiday_name: "Christmas",
      holiday_date: "2020-12-25 00:00:00Z",
      open_at: "8:00 AM",
      close_at: "5:00 PM"
    }
  end

  def location_factory do
    %Location{
      id: UUID.uuid4(),
      location_name: sequence(:location_name, &"Location #{&1}"),
      phone_number: phone_number(),
      # This must be set to make a valid record
      team_id: nil,
      timezone: "PST8PDT",
      api_key: UUID.uuid4(),
      address_1: Faker.Address.street_address(),
      city: Faker.Address.city(),
      state: Faker.Address.state_abbr(),
      postal_code: Faker.Address.postcode(),
      messenger_id: nil,
      mindbody_location_id: nil
    }
  end

  def member_factory do
    %Member{
      id: UUID.uuid4(),
      team_id: nil,
      phone_number: phone_number(),
      first_name: "Bob",
      last_name: "Dobbs",
      email: "bob@dobbs.com",
      status: "active",
      consent: true
    }
  end

  def member_channel_factory do
    %MemberChannel{
      id: UUID.uuid4(),
      channel_id: nil,
      member_id: nil
    }
  end

  def normal_hour_factory do
    %NormalHour{
      id: UUID.uuid4(),
      location_id: nil,
      day_of_week:
        Enum.random(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]),
      open_at: "8:00 AM",
      close_at: "12:00 PM",
      active: true
    }
  end

  def pricing_plan_factory do
    %PricingPlan{
      id: UUID.uuid4(),
      location_id: nil,
      has_daily: true,
      daily: "$5 per day",
      has_weekly: true,
      weekly: "$5 per day",
      has_monthly: true,
      monthly: "$5 per day",
      deleted_at: nil
    }
  end

  def team_factory do
    %Team{
      id: UUID.uuid4(),
      team_name: sequence(:team_name, &"Team #{&1}"),
      website: "www.example.com",
      twilio_flow_id: nil,
      team_member_count: 0,
      use_mindbody: false,
      mindbody_site_id: nil
    }
  end

  def team_member_factory do
    %TeamMember{
      id: UUID.uuid4(),
      location_id: nil,
      team_id: nil,
      user_id: nil,
      deleted_at: nil
    }
  end

  def user_factory do
    %User{
      id: UUID.uuid4(),
      phone_number: phone_number(),
      role: "admin",
      first_name: Faker.Name.first_name(),
      last_name: Faker.Name.last_name(),
      email: Faker.Internet.email(),
      avatar: nil,
      logged_in_at: nil,
      deleted_at: nil
    }
  end

  def wifi_network_factory do
    %WifiNetwork{
      id: UUID.uuid4(),
      location_id: nil,
      network_name: Faker.Company.name(),
      network_pword: Faker.Company.buzzword()
    }
  end
end
