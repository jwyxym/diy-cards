--拉法姆的诅咒
local s,id=GetID()
function s.initial_effect(c)
	-- ① 通常陷阱的发动效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.activate1)
	c:RegisterEffect(e1)
	-- ② 墓地诱发效果（召唤/特召成功时）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.condition2)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.activate2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 记录本回合此卡被送去墓地的标志
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.regflag)
	c:RegisterEffect(e4)
	-- 对方回合结束时清除②发动后的限制标志
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCondition(s.clearcon)
	e5:SetOperation(s.clearop)
	c:RegisterEffect(e5)
	-- 全局限制：当标志 id+400 存在时，自己不能召唤/特召非拉法姆
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetTargetRange(1,0)
	e6:SetCondition(s.limcon)
	e6:SetTarget(s.limfilter)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e7)
end
s.listed_series={0x0cf0}

-- ① 一回合一次标志检查
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id+100)==0
end
-- ① 目标：最多自己场上拉法姆数量的对方表侧卡
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_MZONE,0,nil,0x0cf0)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- ① 效果处理（改用 GetChainInfo 获取目标，避免使用 GetTargetCards）
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	if g then
		local tc = g:GetFirst()
		while tc do
			if tc:IsFaceup() and tc:IsRelateToEffect(e) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE_EFFECT)
				e1:SetReset(RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE)
				e2:SetReset(RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e2)
			end
			tc = g:GetNext()
		end
	end
	Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE+PHASE_END,0,1)
end

-- ② 发动条件
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id+200)>0 then return false end
	if Duel.GetFlagEffect(tp,id+300)>0 then return false end
	local ec=eg:GetFirst()
	return ec:IsSetCard(0x0cf0) and ec:IsControler(tp)
end
-- ② 发动目标（无目标）
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- ② 效果处理
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SSet(tp,c)
		Duel.RegisterFlagEffect(tp,id+400,0,0,1)
		Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	end
end

-- 记录送入墓地
function s.regflag(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id+300,RESET_PHASE+PHASE_END,0,1)
end

-- 清除限制标志
function s.clearcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id+400)
end

-- 限制条件
function s.limcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetFlagEffect(tp,id+400)>0
end
function s.limfilter(e,c)
	return not c:IsSetCard(0x0cf0)
end