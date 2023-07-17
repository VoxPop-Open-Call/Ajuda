import React from "react";

import { capitalizeWord } from "../../../utils/commonUtils";

import styles from "./volunteerServicesComponent.module.scss";

interface VolunteerServicesComponentProps {
  userServices: {
    availabilities: Array<{
      end: string;
      start: string;
      weekDay: number;
    }>;
    taskTypes: Array<{
      code: string;
      createdAt: Date;
      id: string;
      updatedAt: Date;
    }>;
  };
  userConditions: Array<{
    code: string;
    createdAt: Date;
    id: string;
    updatedAt: Date;
  }>;
  userLanguages: Array<{
    code: string;
    name: string;
    nativeName: string;
  }>;
}

const VolunteerServicesComponent: React.FC<VolunteerServicesComponentProps> = ({
  userServices,
  userConditions,
  userLanguages,
}) => {
  // const { taskTypes } = userServices;

  const renderUserServices = (): JSX.Element[] => {
    if (!userServices?.taskTypes?.length) {
      return [<></>];
    }
    const userServicesList = userServices?.taskTypes.map(({ code }) => {
      const service = capitalizeWord(code);
      return (
        <div key={service} className={styles.servicesEntryStyle}>
          {service}
        </div>
      );
    });
    return userServicesList;
  };

  const renderUserConditions = (): string => {
    if (!userConditions?.length) {
      return "";
    }
    const userConditionsList = userConditions.map(({ code }) => {
      let codeList = code.split("-");
      codeList = codeList.map((word) => capitalizeWord(word));
      return codeList.join(" ");
    });
    return userConditionsList.join(", ");
  };

  const renderUserLanguages = (): string => {
    if (!userLanguages?.length) {
      return "";
    }
    const userLanguagesList = userLanguages.map(({ name }) => name);
    return userLanguagesList.join(", ");
  };

  return (
    <div>
      <div>
        <div className={styles.titleStyle}>Services</div>
        <div className={styles.servicesEntryContainerDiv}>
          {renderUserServices()}
        </div>
      </div>

      <div>
        <div className={styles.titleStyle}>Can Help with</div>
        <div className={styles.languageAndConditionsStyle}>
          {renderUserConditions()}
        </div>
      </div>
      <div>
        <div className={styles.titleStyle}>Languages spoken</div>
        <div className={styles.languageAndConditionsStyle}>
          {renderUserLanguages()}
        </div>
      </div>
    </div>
  );
};

export default VolunteerServicesComponent;
