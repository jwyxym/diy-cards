--劫富济贫的义贼
function c21363702.initial_effect(c)
	aux.AddCodeList(c,21363700) 
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,21363702+EFFECT_COUNT_CODE_OATH) 
	e1:SetTarget(c21363702.target)
	e1:SetOperation(c21363702.activate)
	c:RegisterEffect(e1) 
	--Draw
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F) 
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTarget(c21363702.drtg)
	e2:SetOperation(c21363702.drop)
	c:RegisterEffect(e2)
	if not c21363702.global_check then
		c21363702.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c21363702.checkop)
		Duel.RegisterEffect(ge1,0) 
	end
end
function c21363702.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do 
		if tc:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) then 
			Duel.RegisterFlagEffect(tc:GetPreviousControler(),21363702,RESET_PHASE+PHASE_END,0,1)
		end 
		tc=eg:GetNext()
	end
end
function c21363702.filter(c,e,tp)
	return c:IsCode(21363700) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c21363702.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c21363702.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
function c21363702.setfil(c)
	return aux.IsCodeListed(c,21363700) and not c:IsCode(21363702) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c21363702.activate(e,tp,eg,ep,ev,re,r,rp) 
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c21363702.filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.GetFlagEffect(1-tp,21363702)~=0 and Duel.IsExistingMatchingCard(c21363702.setfil,tp,LOCATION_DECK,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(24425055,0)) then 
		Duel.BreakEffect()
		local sc=Duel.SelectMatchingCard(tp,c21363702.setfil,tp,LOCATION_DECK,0,1,1,nil):GetFirst() 
		Duel.SSet(tp,sc) 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(24425055,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(24425055,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
end
function c21363702.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end 
	Duel.SetTargetPlayer(tp) 
	Duel.SetTargetParam(1) 
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c21363702.drop(e,tp,eg,ep,ev,re,r,rp) 
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end






