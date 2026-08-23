--绝大的显现·马塞班恩
local s,id,o=GetID()
function s.initial_effect(c)
	--超量召唤
	aux.AddXyzProcedure(c,nil,6,6,s.ovfilter,aux.Stringid(id,4))
	c:EnableReviveLimit()
	--抽卡    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)    
	--抽卡    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
    e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)   
    local e3=e2:Clone()
    e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end    
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(31280237)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)	
	local h=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(6-h)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,6-h)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	if Duel.GetFlagEffect(tp,id)~=0 then return end
	local c=e:GetHandler()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local h=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if h<6 and Duel.IsPlayerCanDraw(tp,6-h) then
		Duel.Draw(p,6-h,REASON_EFFECT)
    end
    Duel.RegisterFlagEffect(tp,id,0,0,0)
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.thcon)
	e2:SetOperation(s.thop)
    e2:SetCountLimit(2)
	Duel.RegisterEffect(e2,tp)    
end
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and re:IsActiveType(TYPE_SPELL) and rc:IsSetCard(0xacaa) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end		
function s.thop(e,tp,eg,ep,ev,re,r,rp)	
	local rc=re:GetHandler()
	if rc:IsRelateToEffect(re) and (rc:IsAbleToHand() or rc:IsCanTurnSet())
    	and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_CARD,0,id)
    	rc:CancelToGrave()
        local op=aux.SelectFromOptions(tp,
			{rc:IsAbleToHand(),aux.Stringid(id,7),1},
			{rc:IsCanTurnSet(),aux.Stringid(id,8),2})
        if op==1 then Duel.SendtoHand(rc,nil,REASON_EFFECT)
        elseif op==2 then 
        	Duel.ChangePosition(rc,POS_FACEDOWN)
			Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
        end    
	end        
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetTurnPlayer()==tp
end    
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end  
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<1 then return end
	Duel.ConfirmCards(1-tp,g)
	if g:GetClassCount(Card.GetCode)==g:GetCount() and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    	and aux.NecroValleyFilter()(c) and Duel.GetFlagEffect(tp,id+o)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
        Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
    Duel.ShuffleDeck(tp)
end
function s.phfilter(c)
	return c:IsSetCard(0xacaa) and not c:IsPublic()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<1 then return end
	Duel.ConfirmCards(1-tp,g)
	if g:GetClassCount(Card.GetCode)==g:GetCount() and Duel.IsPlayerCanDraw(tp,1)
    	and Duel.IsExistingMatchingCard(s.phfilter,tp,LOCATION_HAND,0,1,nil)
    	and Duel.GetFlagEffect(tp,id+o*2)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
    	Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local tc=Duel.SelectMatchingCard(tp,s.phfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
        if tc then
        	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_PUBLIC)
			e1:SetReset(RESET_CHAIN)
			tc:RegisterEffect(e1)
            local hg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,tc)
        	if hg:GetCount()>0 and Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)~=0 then
    			local ct=Duel.GetOperatedGroup():GetCount()
                local dt=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
                if ct>dt then ct=dt end
    			if Duel.Draw(tp,ct,REASON_EFFECT)~=0 then 
                	Duel.ShuffleHand(tp)                    
                	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
            			local WIN_REASON_DISASTER_LEO=0xacaa
               	 		Duel.BreakEffect()
                		Duel.Win(tp,WIN_REASON_DISASTER_LEO)
                    end    
               	end     
            end
            e1:Reset()
        end    
	end
    Duel.ShuffleDeck(tp)
end