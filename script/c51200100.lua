--妖刀姬
function c51200100.initial_effect(c)
	c:SetUniqueOnField(1,0,c51200100.filter,LOCATION_MZONE)
	--战破抗性
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c51200100.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--墓地·除外苏生
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCountLimit(1,51200100)
	e4:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e4:SetCondition(c51200100.spcon)
	e4:SetTarget(c51200100.sptg)
	e4:SetOperation(c51200100.spop)
	c:RegisterEffect(e4)
	--抽卡
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(51200100,0))
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetCountLimit(1,51200101)
	e5:SetTarget(c51200100.target)
	e5:SetOperation(c51200100.activate)
	c:RegisterEffect(e5)
end
	function c51200100.filter(c)
	return c:IsSetCard(0x65d) and not c:IsLocation(LOCATION_EXTRA)
end
	function c51200100.indcon(e)
	return e:GetHandler():IsAttackPos()
end
	function c51200100.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) 
		and c:IsPreviousSetCard(0x65d) and (rp==1-tp and c:IsReason(REASON_EFFECT))
end
	function c51200100.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51200100.cfilter,1,nil,tp,rp)
end
	function c51200100.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
	function c51200100.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
	function c51200100.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
	function c51200100.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end