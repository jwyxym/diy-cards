--巨械时钟盘域
function c35100307.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--decrease tribute
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35100307,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(c35100307.ntcon)
	e2:SetTarget(c35100307.nttg)
	c:RegisterEffect(e2)
	--extra summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35100307,1))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(c35100307.sumcon)
	e3:SetTarget(c35100307.sumtg)
	e3:SetOperation(c35100307.sumop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--draw
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(35100307,3))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_TO_DECK)
	e5:SetCondition(c35100307.drcon)
	e5:SetTarget(c35100307.drtg)
	e5:SetOperation(c35100307.drop)
	c:RegisterEffect(e5)
end
function c35100307.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c35100307.nttg(e,c)
	return c:IsSetCard(0x4a)
end
function c35100307.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x4a) and c:IsControler(tp) and c:IsSummonLocation(LOCATION_HAND+LOCATION_DECK)
end
function c35100307.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35100307.cfilter,1,nil,tp)
end
function c35100307.tgfilter(c,tp,eg)
	return eg:IsContains(c) and Duel.IsExistingMatchingCard(c35100307.thfilter,tp,LOCATION_HAND,0,1,nil,c:GetCode())
end
function c35100307.thfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsSummonable(true,nil) and ((c:IsAttack(0) and c:IsDefense(0)) or (c:IsAttack(4000) and c:IsDefense(4000)))
end
function c35100307.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35100307.tgfilter(chkc,tp,eg) end
	if chk==0 then return Duel.IsExistingTarget(c35100307.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp,eg)
		and Duel.GetFlagEffect(tp,35100307)==0 end
	Duel.RegisterFlagEffect(tp,35100307,RESET_CHAIN,0,1)
	if eg:GetCount()==1 then
		Duel.SetTargetCard(eg)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,c35100307.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,eg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c35100307.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local code=tc:GetCode()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,c35100307.thfilter,tp,LOCATION_HAND,0,1,1,nil,code)
		local ec=g:GetFirst()
		if ec then
			Duel.Summon(tp,ec,true,nil)
			local e0=Effect.CreateEffect(c)
			e0:SetType(EFFECT_TYPE_FIELD)
			e0:SetCode(EFFECT_CANNOT_SUMMON)
			e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e0:SetTargetRange(1,0)
			e0:SetTarget(c35100307.thlimit)
			e0:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e0,tp)
			local e1=Effect.CreateEffect(tc)
	        e1:SetDescription(aux.Stringid(35100307,2))
	        e1:SetCategory(CATEGORY_NEGATE)
	        e1:SetType(EFFECT_TYPE_QUICK_O)
	        e1:SetCode(EVENT_CHAINING)
	        e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	        e1:SetRange(LOCATION_MZONE)
	        e1:SetCountLimit(1)
	        e1:SetCondition(c35100307.negcon)
	        e1:SetTarget(c35100307.negtg)
	        e1:SetOperation(c35100307.negop)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	        tc:RegisterEffect(e1)
		end
	end
end
function c35100307.thlimit(e,c,tp,re,code)
	return c:IsCode(code) and re and re:GetHandler():IsCode(35100307)
end
function c35100307.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) and rp==1-tp
end
function c35100307.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function c35100307.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
function c35100307.drcon(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:GetFirst()
	return eg:GetCount()==1 and tg:IsSetCard(0x4a) and tg:IsPreviousLocation(LOCATION_MZONE) and tg:IsPreviousPosition(POS_FACEUP)
end
function c35100307.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c35100307.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	end
end