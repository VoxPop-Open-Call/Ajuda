import React from "react";

import styles from "./userEmergencyContactsComponent.module.scss";

interface UserEmergencyContactsComponentProps {
  userContacts: {
    emergencyContacts: Array<{
      name: string;
      phoneNumber: string;
    }>;
  };
}

const UserEmergencyContactsComponent: React.FC<
  UserEmergencyContactsComponentProps
> = ({ userContacts }) => {
  // const { emergencyContacts } = userContacts;
  const renderUserContacts = (): JSX.Element[] => {
    if (!userContacts?.emergencyContacts?.length) {
      return [<></>];
    }
    return userContacts.emergencyContacts.map(({ name, phoneNumber }) => (
      <div key={name} className={styles.contactContainerDiv}>
        <div className={styles.contactNameStyle}>{name}</div>
        <div className={styles.contactPhoneNumber}>{phoneNumber}</div>
      </div>
    ));
  };

  return (
    <div className={styles.containerDiv}>
      <div className={styles.titleStyle}>Emergency Contacts</div>
      <div>{renderUserContacts()}</div>
    </div>
  );
};

export default UserEmergencyContactsComponent;
