-- 王家魔族·死亡厄运歌手 (ID: 20263269)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：这张卡把2只7星以上怪兽解放来进行上级召唤的场合才能发动。对方场上的怪兽全部破坏。那之后，给予对手这个效果破坏的怪兽原本等级数值×200的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	-- 注册素材检查：记录解放的素材是否包含2只7星以上怪兽
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)

	-- ②：只要上级召唤的这张卡在场上表侧表示存在，对方不能在战斗阶段把卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.actcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end

-- ==================== 效果 ① 相关处理 ====================
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:FilterCount(Card.IsLevelAbove,nil,7)>=2 then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	-- 校验为上级召唤，且解放素材中包含至少2只7星以上怪兽
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
		and (e:GetLabel()==1 or (mg and mg:FilterCount(Card.IsLevelAbove,nil,7)>=2))
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	-- 严格使用原生标准的 SetOperationInfo
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		local sum_lv=0
		for tc in aux.Next(og) do
			local lv=tc:GetOriginalLevel()
			if lv>0 then
				sum_lv=sum_lv+lv
			end
		end
		-- 若存在原本等级大于0的怪兽，则给予对方对应等级数值×200的伤害
		if sum_lv>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,sum_lv*200,REASON_EFFECT)
		end
	end
end

-- ==================== 效果 ② 相关处理 ====================
function s.actcon(e)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	-- 上级召唤状态且处于战斗阶段区间（BP开始 ~ BP结束）
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
		and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end