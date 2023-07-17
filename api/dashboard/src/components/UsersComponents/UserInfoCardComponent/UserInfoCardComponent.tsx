import React from "react";

import { CCard, CCardBody } from "@coreui/react";

import { UserProps } from "../../../Controllers/UserControllers/UsersApi";
import VolunteerAvailabilityComponent from "../../VolunteersComponents/VolunteerAvailabilityComponent/VolunteerAvailabilityComponent";
import VolunteerServicesComponent from "../../VolunteersComponents/VolunteerServicesComponent/VolunteerServicesComponent";
import UserContactCardComponent from "../UserContactCardComponent/UserContactCardComponent";
import UserEmergencyContactsComponent from "../UserEmergencyContactsComponent/UserEmergencyContactsComponent";
import UserHelpAreaComponent from "../UserHelpAreaComponent/UserHelpAreaComponent";
import UserServicesComponent from "../UserServicesComponent/UserServicesComponent";

import styles from "./userInfoCardComponent.module.scss";

interface UserInfoCardComponentProps {
  userDetails: UserProps;
  isVolunteer: boolean;
}

const UserInfoCardComponent: React.FC<UserInfoCardComponentProps> = ({
  userDetails,
  isVolunteer,
}): JSX.Element => {
  const {
    name,
    phoneNumber,
    birthday,
    email,
    createdAt,
    rating,
    image,
    location,
    volunteer,
    conditions,
    languages,
    elder,
  } = userDetails;

  const renderVolunteerServices = (): JSX.Element => {
    if (isVolunteer) {
      return (
        <VolunteerServicesComponent
          userServices={volunteer}
          userConditions={conditions}
          userLanguages={languages}
        />
      );
    }
    return (
      <UserServicesComponent
        userConditions={conditions}
        userLanguages={languages}
      />
    );
  };

  const renderVolunteerAvailability = (): JSX.Element => {
    if (isVolunteer) {
      return <VolunteerAvailabilityComponent userAvailability={volunteer} />;
    }
    return <UserEmergencyContactsComponent userContacts={elder} />;
  };

  return (
    <CCard className={styles.cardStyle}>
      <CCardBody className={styles.cardBodyStyle}>
        <UserContactCardComponent
          image={image}
          name={name}
          phoneNumber={phoneNumber}
          birthday={birthday}
          email={email}
          createdAt={createdAt}
          rating={rating}
          isVolunteer={isVolunteer}
        />
        <hr className={styles.dividerStyle} />
        <div className={styles.volunteerQualificationsContainerDiv}>
          <UserHelpAreaComponent
            userLocation={location}
            isVolunteer={isVolunteer}
          />
          {renderVolunteerServices()}
          {renderVolunteerAvailability()}
        </div>
      </CCardBody>
    </CCard>
  );
};

export default UserInfoCardComponent;
