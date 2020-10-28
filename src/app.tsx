import { Button } from '@material-ui/core';
import Axios from 'axios';
import React, { useEffect, useState } from 'react';

export const App = () => {
  const [state, updateState] = useState<{username: string}>({username: ''})
  
  useEffect(() => {
    async function getStuff() {
      const {data } = await Axios.get<{username: string}>("http://localhost:3000/stuff");
    
      updateState(data)
    }
    getStuff()
  })


  return (<Button variant="contained" color="primary">
    {state.username}
</Button>)
}