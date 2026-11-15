--探险者-布莱恩·铜须
local s,id=GetID()
s.pending = s.pending or {}

function s.initial_effect(c)
	-- ① 记录召唤诱发效果，连锁结束后再执行一次（效果处理两次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.doublecon)
	e1:SetOperation(s.doubleop1)
	c:RegisterEffect(e1)

	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetCode(EVENT_CHAIN_END)
	e1b:SetRange(LOCATION_MZONE)
	e1b:SetCondition(s.endcon)
	e1b:SetOperation(s.endop)
	c:RegisterEffect(e1b)

	-- ② 自己主要阶段才能发动。进行1只怪兽的召唤（额外召唤）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.sumcon)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)

	-- ③ 这张卡被送去墓地的场合才能发动。从卡组把1张「探险者」卡加入手卡
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

-- ===== ① 记录与延迟执行 =====
function s.doublecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() then return false end
	local eff=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
	if not eff then return false end
	local code=eff:GetCode()
	if code~=EVENT_SUMMON_SUCCESS and code~=EVENT_SPSUMMON_SUCCESS and code~=EVENT_FLIP_SUMMON_SUCCESS then
		return false
	end
	if eff:GetHandlerPlayer()~=tp then return false end
	return true
end

function s.doubleop1(e,tp,eg,ep,ev,re,r,rp)
	local eff=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
	if not eff then return end
	-- 同一效果只记录一次
	for _,info in ipairs(s.pending) do
		if info.eff==eff then return end
	end
	s.pending[#s.pending+1]={eff=eff,re=re,rp=rp,tp=tp}
end

function s.endcon(e,tp,eg,ep,ev,re,r,rp)
	return #s.pending>0
end

function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsFaceup() or not c:IsLocation(LOCATION_MZONE) then
		s.pending={}
		return
	end
	local list=s.pending
	s.pending={}
	for _,info in ipairs(list) do
		local eff=info.eff
		if eff and eff:GetHandler() then
			local op=eff:GetOperation()
			if op then
				op(eff,info.tp,Group.CreateGroup(),0,0,info.re,0,info.rp)
			end
		end
	end
end

-- ===== ② 额外召唤 =====
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.Summon(tp,g:GetFirst(),true,nil)
	end
end

-- ===== ③ 检索 =====
function s.thfilter(c)
	return c:IsSetCard(0x0cf3) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end