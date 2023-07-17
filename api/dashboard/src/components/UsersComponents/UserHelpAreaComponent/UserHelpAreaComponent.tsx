import React from "react";

import LeafletMapComponent from "../../common/LeafletMapComponent/LeafletMapComponent";

import styles from "./userHelpAreaComponent.module.scss";

interface UserHelpAreaComponentProps {
  userLocation?: {
    address: string;
    lat: number;
    long: number;
    radius: number;
  };
  isVolunteer: boolean;
}

const UserHelpAreaComponent: React.FC<UserHelpAreaComponentProps> = ({
  userLocation,
  isVolunteer,
}) => {
  // const { address, lat, long, radius } = userLocation;
  return (
    <div>
      <div className={styles.titleStyle}>
        {isVolunteer ? "Help Area" : "Residence Area"}
      </div>
      <div className={styles.addressStyle}>
        {userLocation?.address ? userLocation.address : ""}
      </div>
      <div className={styles.mapContainerDiv}>
        <LeafletMapComponent
          coordinates={[
            userLocation?.lat ? userLocation.lat : 0,
            userLocation?.long ? userLocation.long : 0,
          ]}
          radius={userLocation?.radius ? userLocation.radius : 0}
        />
      </div>
      <div className={styles.maxDistanceContainerDiv}>
        <div className={styles.maxDistanceFieldStyle}>Maximum distance:</div>
        <div className={styles.maxDistanceValueStyle}>
          {userLocation?.radius ? userLocation.radius : "0"} km
        </div>
      </div>
    </div>
  );
};

export default UserHelpAreaComponent;
