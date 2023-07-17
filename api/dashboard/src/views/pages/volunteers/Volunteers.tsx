import React, { useCallback, useEffect, useState } from "react";

import { CCard, CCardBody } from "@coreui/react";

import VolunteersTableComponent from "../../../components/VolunteersComponents/VolunteersTableComponent/VolunteersTableComponent";
import { UserProps } from "../../../Controllers/UserControllers/UsersApi";
import { getVolunteerList } from "../../../Controllers/VolunteersControllers/VolunteersApi";

import styles from "./volunteers.module.scss";

const Volunteers: React.FC = (): JSX.Element => {
  const [volunteerList, setVolunteerList] = useState<UserProps[]>([]);
  const [pagination, setPagination] = useState({
    limit: 10,
    offset: 0,
    orderBy: "id asc",
    filter: {},
  });

  const volunteerListFetch = useCallback(() => {
    getVolunteerList(pagination)
      .then(({ data }) => {
        const _data = data.map((obj) => ({
          ...obj,
          _props: { className: styles.tableRowStyle },
        }));
        setVolunteerList(_data);
      })
      .catch(({ response }) => {
        window.alert(response.data.error.message);
      });
  }, [pagination]);

  useEffect(() => {
    volunteerListFetch();
  }, [volunteerListFetch]);

  return (
    <CCard className={styles.containingCard}>
      <CCardBody className={styles.containingCardBody}>
        <div className={styles.pageTitle}>Volunteers</div>
        <div className={styles.tableDiv}>
          <VolunteersTableComponent
            tableData={volunteerList}
            pagination={pagination}
            setPagination={setPagination}
          />
        </div>
      </CCardBody>
    </CCard>
  );
};

export default Volunteers;
