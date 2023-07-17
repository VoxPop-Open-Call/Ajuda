import React, { useState } from "react";

import {
  CButton,
  CCard,
  CCardBody,
  CFormInput,
  CFormLabel,
  CInputGroup,
} from "@coreui/react";
import { useNavigate } from "react-router";

import LoginImage from "../../../assets/loginImage/ajudamais-bg@0.8x.jpg";
import { userLoginInfo } from "../../../Controllers/OAuth/OAuth";

import styles from "./login.module.scss";

interface LoginProps {
  onLoggedChange: (value: boolean) => void;
}

const Login: React.FC<LoginProps> = ({ onLoggedChange }) => {
  const navigate = useNavigate();
  const [credentials, setCredentials] = useState({
    username: "",
    password: "",
    error: "",
  });

  const handleOnChange = (event: React.ChangeEvent<HTMLInputElement>): void => {
    const { name, value }: { name: string; value: string } = event.target;
    setCredentials((currentState) => ({
      ...currentState,
      [name]: value,
      error: "",
    }));
  };

  const validateCredentials = (data: {
    username: string;
    password: string;
  }): boolean => {
    if (data?.username && data?.password) {
      return true;
    }
    return false;
  };

  const handleSubmit = (): void => {
    if (validateCredentials(credentials)) {
      userLoginInfo({
        username: credentials.username,
        password: credentials.password,
      })
        .then(({ data }) => {
          localStorage.setItem("encodedToken", data.access_token);
          localStorage.setItem("refreshToken", data.refresh_token);
          onLoggedChange(true);
          navigate("/dashboard");
        })
        .catch(({ response }) => {
          setCredentials((state) => ({
            ...state,
            error: response.data.error_description,
          }));
        });
    } else {
      setCredentials((state) => ({
        ...state,
        error: "Both fields need to be filled.",
      }));
    }
  };

  const renderError = (): string | null => {
    if (credentials?.error) {
      return credentials.error;
    }
    return null;
  };

  return (
    <div
      className={styles.positionDiv}
      onKeyDown={(e) => {
        if (e.key === "Enter") {
          handleSubmit();
        }
      }}
    >
      <CCard className={styles.cardStyle}>
        <div className={styles.loginContainerDiv}>
          <img src={LoginImage} className={styles.loginImageDiv} />
          <CCardBody className={styles.cardBodyStyle}>
            <div className={styles.titleStyle}>Welcome back.</div>
            <div className={styles.inputFieldsDiv}>
              <div className={styles.inputContainerDiv}>
                <CFormLabel className={styles.loginFieldStyle}>
                  Email
                </CFormLabel>
                <CInputGroup>
                  <CFormInput
                    className={styles.loginFields}
                    name="username"
                    placeholder="Email"
                    autoComplete="username"
                    onChange={(e) => handleOnChange(e)}
                  />
                </CInputGroup>
              </div>
              <div className={styles.inputContainerDiv}>
                <CFormLabel className={styles.loginFieldStyle}>
                  Password
                </CFormLabel>
                <CInputGroup>
                  <CFormInput
                    className={styles.loginFields}
                    name="password"
                    placeholder="Password"
                    type="password"
                    autoComplete="current-password"
                    onChange={(e) => handleOnChange(e)}
                  />
                </CInputGroup>
              </div>
              <div className={styles.buttonDivStyle}>
                <CButton className={styles.buttonStyle} onClick={handleSubmit}>
                  Login
                </CButton>
                <div className={styles.errorTextStyle}>{renderError()}</div>
              </div>
            </div>
          </CCardBody>
        </div>
      </CCard>
    </div>
  );
};

export default Login;
