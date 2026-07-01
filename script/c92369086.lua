--鬼计集会
function c92369086.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c) 
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN) 
	c:RegisterEffect(e0)
	--atklimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(aux.TargetBoolFunction(Card.IsFacedown))
	c:RegisterEffect(e1)
	--direct attack
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DIRECT_ATTACK)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c92369086.dirtg)
	c:RegisterEffect(e5)
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_MSET)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_FZONE) 
	e2:SetCondition(c92369086.srcon1)
	e2:SetTarget(c92369086.srtg)
	e2:SetOperation(c92369086.srop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SSET)
	e3:SetCondition(c92369086.srcon1)
	c:RegisterEffect(e3)
	local e3=e2:Clone()
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(c92369086.srcon2)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c92369086.srcon3)
	c:RegisterEffect(e4)
	--sp 
	local e6=Effect.CreateEffect(c) 
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCountLimit(1,92369086)  
	e6:SetTarget(c92369086.sptg)
	e6:SetOperation(c92369086.spop)
	c:RegisterEffect(e6)
end
function c92369086.srcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
function c92369086.cfilter2(c,tp)
	return (c:IsPreviousPosition(POS_FACEDOWN) and c:IsFaceup()
		 or c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown()) 
		and c:IsControler(tp)
end
function c92369086.srcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c92369086.cfilter2,1,nil,tp)
end
function c92369086.cfilter3(c,tp)
	return c:IsFacedown() and c:IsControler(tp)
end
function c92369086.srcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c92369086.cfilter3,1,nil,tp)
end
function c92369086.srfil(c) 
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x8d) 
end 
function c92369086.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c92369086.srfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) and e:GetHandler():GetFlagEffect(92369086)==0 end 
	e:GetHandler():RegisterFlagEffect(92369086,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c92369086.srop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.SelectMatchingCard(tp,c92369086.srfil,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst() 
	if tc then
		Duel.SendtoHand(tc,tp,REASON_EFFECT) 
		Duel.ConfirmCards(1-tp,tc) 
	end 
end 
function c92369086.spfil(c,e,tp) 
	return c:IsSetCard(0x8d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)   
end 
function c92369086.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c92369086.spfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end 
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function c92369086.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end 
	local tc=Duel.SelectMatchingCard(tp,c92369086.spfil,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst() 
	if tc then 
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE+POS_FACEDOWN_DEFENSE) 
		if tc:IsFacedown() then 
			Duel.ConfirmCards(1-tp,tc) 
		end 
	end 
end 

function c92369086.dirtg(e,c)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end





