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
    e1:SetLabel(id)
	c:RegisterEffect(e1)    
	--抽卡    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
    e2:SetCondition(s.effcon)
	e2:SetTarget(s.efftg)
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
	if Duel.GetFlagEffect(tp,ct)~=0 then return end
	local c=e:GetHandler()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local h=Duel.GetFieldGroupCount(p,LOCATION_HAND,0)
	if h<6 and Duel.IsPlayerCanDraw(tp,6-h) then
		Duel.Draw(p,6-h,REASON_EFFECT)
    end
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,5))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.tdcon)
	e2:SetOperation(s.tdop)
    e2:SetCountLimit(2)
	Duel.RegisterEffect(e2,tp)
    Duel.RegisterFlagEffect(tp,id,0,0,1)
end
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
function s.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0xacaa) and c:IsAbleToDeck() 
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and (re:IsActiveType(TYPE_SPELL) and rc:IsSetCard(0xacaa))
		and Duel.IsExistingMatchingCard(s.tfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)	
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
		end
	end        
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetTurnPlayer()==tp
end    
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end  
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<1 then return end
	Duel.ConfirmCards(1-tp,g)
	if g:GetClassCount(Card.GetCode)==g:GetCount() and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    	and aux.NecroValleyFilter()(c) and Duel.GetFlagEffect(tp,id+o)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
        Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,c)
            if sg:GetCount()>0 then
        		Duel.BreakEffect()
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end                
        end
	end
    Duel.ShuffleDeck(tp)
end
function s.tgfilter(c)
	return not c:IsSetCard(0xacaa) and c:IsDiscardable()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<1 then return end
	Duel.ConfirmCards(1-tp,g)
	if g:GetClassCount(Card.GetCode)==g:GetCount() and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 
    	and Duel.GetFlagEffect(tp,id+o*2)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,7)) then
    	Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
    	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
    	if hg:GetCount()<1 then return end
		Duel.ConfirmCards(1-tp,hg)
        local ct=Duel.GetMatchingGroupCount(s.tgfilter,tp,LOCATION_HAND,0,nil)
    	if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) and Duel.IsPlayerCanDraw(tp,ct) then
    		local dt=Duel.DiscardHand(tp,s.tgfilter,ct,ct,REASON_EFFECT+REASON_DISCARD)
    		if dt~=0 and Duel.Draw(tp,dt,REASON_EFFECT)~=0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
            	local WIN_REASON_DISASTER_LEO=0xacaa
                Duel.BreakEffect()
                Duel.Win(tp,WIN_REASON_DISASTER_LEO)
            end
        end    
	end
    Duel.ShuffleDeck(tp)
end