-- 永续魔法 七皇之守望 (ID: 20263243)
local s,id,o=GetID()
o=o or 1 -- 安全保底
local SET_SEVENTH=0x175 -- 「七皇」官方字段代码
local SET_NUMBER=0x48   -- 「No.」官方字段代码
local SET_CNO=0x1048    -- 「混沌No.」官方字段代码

function s.initial_effect(c)
	-- 永续魔法卡片表侧激活
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	-- ①：只要这张卡在魔陷区存在，自己场上的「No.」怪兽不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)

	-- ②：1回合1次，主阶以自己·对方场上No.101~No.107为对象：在上方叠放同阶或高1阶的「混沌No.」超量怪兽超量召唤 (HOPT: id)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)

	-- ③：自己·对方受到效果伤害的场合可以发动：选对方场上1张表侧卡成为自己超量怪兽的素材 (HOPT: id+o*100)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_DAMAGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id+o*100)
	e4:SetCondition(s.damcon)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end

-- ==================== ① 效果：No.怪兽战斗破坏保护 ====================
function s.indtg(e,c)
	return c:IsSetCard(SET_NUMBER)
end

-- ==================== ② 效果：全兼容 No.101~No.107 叠放超量召唤 ====================
-- 全兼容 No.101 ~ No.107 编号识别函数（包含所有官方 No./CNo. 及自定义卡号）
function s.get_no_number(c)
	local no=aux.GetXyzNumber(c)
	if no and no>=101 and no<=107 then return no end
	local code=c:GetOriginalCode()
	-- 完整的 No.101 ~ No.107（含所有 CNo. 与自定义形态）穿透映射表
	local no_map={
		-- No.101 & CNo.101
		[48739166]=101, [12744567]=101,
		-- No.102 & CNo.102（涵盖所有官方与自定义形态）
		[49678559]=102, [67173574]=102, [20263241]=102, [20263242]=102, [20263245]=102,
		-- No.103 & CNo.103
		[94380860]=103, [20785975]=103,
		-- No.104 & CNo.104
		[2061963]=104,  [49456901]=104,
		-- No.105 & CNo.105
		[85121942]=105, [59627613]=105,
		-- No.106 & CNo.106
		[63746411]=106, [55888017]=106,
		-- No.107 & CNo.107
		[88177324]=107, [68396121]=107,
	}
	return no_map[code]
end

-- 判定是否属于「混沌No.」超量怪兽
function s.is_cno(c)
	return c:IsSetCard(SET_CNO) or c:IsSetCard(0x1048) or c:IsCode(67173574, 12744567, 20785975, 49456901, 59627613, 55888017, 68396121, 20263242, 20263245)
end

-- 智能空位计算：区分对象怪兽在自己场上还是对方场上
function s.zonecheck(tp,tc,sc)
	if tc:IsControler(tp) then
		return Duel.GetLocationCountFromEx(tp,tp,tc,sc)>0
	else
		return Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0
	end
end

function s.xyzfilter(c,e,tp,tc,rk)
	return s.is_cno(c) and c:IsType(TYPE_XYZ)
		and (c:GetRank()==rk or c:GetRank()==rk+1)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		and s.zonecheck(tp,tc,c)
end

function s.targetfilter(c,e,tp)
	local no=s.get_no_number(c)
	if not (c:IsFaceup() and c:IsType(TYPE_XYZ) and no and no>=101 and no<=107) then return false end
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank())
end

function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.targetfilter(chkc,e,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.targetfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.targetfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsImmuneToEffect(e) then return end
	local rk=tc:GetRank()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,rk)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if #mg>0 then
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,Group.FromCards(tc))
		if Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
end

-- ==================== ③ 效果：受到效果伤害吸收对方卡为素材 ====================
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)~=0
end

function s.oppocardfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and c:IsCanOverlay()
end

function s.xyzmonfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.oppocardfilter,tp,0,LOCATION_ONFIELD,1,nil)
			and Duel.IsExistingMatchingCard(s.xyzmonfilter,tp,LOCATION_MZONE,0,1,nil)
	end
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local og=Duel.GetMatchingGroup(s.oppocardfilter,tp,0,LOCATION_ONFIELD,nil)
	local xg=Duel.GetMatchingGroup(s.xyzmonfilter,tp,LOCATION_MZONE,0,nil)
	if #og==0 or #xg==0 then return end

	-- 1. 选对方场上 1 张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=og:Select(tp,1,1,nil):GetFirst()
	if not tc then return end

	-- 2. 选自己场上 1 只超量怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local xc=xg:Select(tp,1,1,nil):GetFirst()
	if xc and not tc:IsImmuneToEffect(e) then
		local og_prev=tc:GetOverlayGroup()
		if #og_prev>0 then
			Duel.SendtoGrave(og_prev,REASON_RULE)
		end
		Duel.Overlay(xc,Group.FromCards(tc))
	end
end