import React from "react";

import styles from "./userServicesComponent.module.scss";

interface UserServicesComponentProps {
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

const UserServicesComponent: React.FC<UserServicesComponentProps> = ({
  userConditions,
  userLanguages,
}) => {
  const renderUserConditions = (): string => {
    if (!userConditions?.length) {
      return "";
    }
    const userConditionsList = userConditions.map(({ code }) => {
      let codeList = code.split("-");
      codeList = codeList.map((word) => {
        const firstLetter = word.charAt(0).toUpperCase();
        const restWord = word.slice(1).toLowerCase();
        return firstLetter + restWord;
      });
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
        <div className={styles.titleStyle}>Conditions</div>
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

export default UserServicesComponent;
