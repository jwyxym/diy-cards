-- 逆转的破坏龙 甘多拉 (ID: 20263230)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 这张卡不能特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e0)

	-- ①-A：抽到这张卡时：展示手卡自身，进行1次龙族怪兽召唤 (HOPT: id)
	local e1_1=Effect.CreateEffect(c)
	e1_1:SetDescription(aux.Stringid(id,0))
	e1_1:SetCategory(CATEGORY_SUMMON)
	e1_1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1_1:SetProperty(EFFECT_FLAG_DELAY)
	e1_1:SetCode(EVENT_DRAW)
	e1_1:SetRange(LOCATION_HAND)
	e1_1:SetCountLimit(1,id)
	e1_1:SetCondition(s.drawcon)
	e1_1:SetCost(s.revealcost)
	e1_1:SetTarget(s.sumtg)
	e1_1:SetOperation(s.sumop)
	c:RegisterEffect(e1_1)

	-- ①-B/C：对方发动特召墓地怪兽效果 / 对方在自己回合发动魔陷时：展示手卡自身，进行1次龙族怪兽召唤 (HOPT: id)
	local e1_2=Effect.CreateEffect(c)
	e1_2:SetDescription(aux.Stringid(id,0))
	e1_2:SetCategory(CATEGORY_SUMMON)
	e1_2:SetType(EFFECT_TYPE_QUICK_O)
	e1_2:SetCode(EVENT_CHAINING)
	e1_2:SetRange(LOCATION_HAND)
	e1_2:SetCountLimit(1,id) -- 与 ①-A 共享限制码 id
	e1_2:SetCondition(s.chaincon)
	e1_2:SetCost(s.revealcost)
	e1_2:SetTarget(s.sumtg)
	e1_2:SetOperation(s.sumop)
	c:RegisterEffect(e1_2)

	-- ②：召唤成功的场合强制发动。其他表侧卡效果无效破坏并除外，给予破坏数×300伤害 (HOPT: id+o*100)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_DAMAGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)

	-- ③：攻击力上升除外状态的卡的数量×300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果：三大时点判断与召唤 ====================
-- 时点 A：抽到这张卡时
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler())
end

-- 时点 B & C：特召墓地效果 或 对方在自己回合发动魔陷
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp then return false end
	-- 时点 B：包含把墓地的怪兽特殊召唤的效果
	local ex,tg,tc,p,loc=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	local b_cond=ex and (loc&LOCATION_GRAVE~=0 or (tg and tg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)))
	-- 时点 C：对方在自己的回合把魔法·陷阱卡的效果发动
	local c_cond=Duel.GetTurnPlayer()==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
	return b_cond or c_cond
end

function s.revealcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	Duel.ConfirmCards(1-tp,c)
end

function s.sumfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsSummonable(true,nil)
end

function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 如果召唤的是「甘多拉」(0xf6) 怪兽，召唤成功时对方不能发动卡的效果
		if tc:IsSetCard(0xf6) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SUMMON_SUCCESS)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.actlimcon)
			e1:SetOperation(s.actlimop)
			Duel.RegisterEffect(e1,tp)
		end
		Duel.Summon(tp,tc,true,nil)
	end
end

function s.actlimcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return eg:IsContains(tc)
end

function s.actlimop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(s.chainlm)
	e:Reset()
end

function s.chainlm(e,rp,tp)
	return tp==rp
end

-- ==================== ② 效果：全场表侧卡无效破坏除外 + 扣血 ====================
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*300)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	if #g>0 then
		-- 1. 无效这些卡在场上的效果
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 2. 破坏并除外
		local ct=Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
		-- 3. 给予破坏数量×300的伤害
		if ct>0 then
			Duel.Damage(1-tp,ct*300,REASON_EFFECT)
		end
	end
end

-- ==================== ③ 效果：除外卡数量加攻 ====================
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(0,LOCATION_REMOVED,LOCATION_REMOVED)*300
end